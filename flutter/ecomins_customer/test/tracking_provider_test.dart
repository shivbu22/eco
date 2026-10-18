import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:ecomins_customer/features/tracking/tracking_provider.dart';

// ── Fake TrackingProvider ────────────────────────────────────────────────────
//
// Overrides [startTracking] to inject a [StreamController] instead of opening
// a real WebSocket, so tests run without network access.

class FakeTrackingProvider extends TrackingProvider {
  StreamController<dynamic>? fakeStream;

  @override
  void startTracking(String jobId, String token) {
    stopTracking();
    this.jobId = jobId;
    fakeStream = StreamController<dynamic>();
    isConnected = true;
    notifyListeners();

    // Listen to the fake stream and route messages through the real handler.
    fakeStream!.stream.listen(
      (data) => handleMessageForTest(data),
      onDone: () {
        isConnected = false;
        notifyListeners();
      },
    );
  }

  /// Pushes a raw JSON string into the fake stream.
  void pushMessage(Map<String, dynamic> payload) {
    fakeStream?.add(jsonEncode(payload));
  }

  /// Closes the fake stream (simulates WebSocket disconnect).
  void closeStream() {
    fakeStream?.close();
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

Map<String, dynamic> _statusMsg(String status) => {'status': status};

Map<String, dynamic> _locationMsg(String status, double lat, double lng) => {
      'status': status,
      'worker': {'lat': lat, 'lng': lng},
    };

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('isValidTransition', () {
    test('forward transitions are accepted', () {
      expect(isValidTransition(null, JobStatus.pending), isTrue);
      expect(isValidTransition(JobStatus.pending, JobStatus.assigned), isTrue);
      expect(isValidTransition(JobStatus.assigned, JobStatus.enRoute), isTrue);
      expect(isValidTransition(JobStatus.enRoute, JobStatus.inProgress), isTrue);
      expect(isValidTransition(JobStatus.inProgress, JobStatus.completed), isTrue);
    });

    test('cancelled is valid from any non-terminal state', () {
      expect(isValidTransition(JobStatus.pending, JobStatus.cancelled), isTrue);
      expect(isValidTransition(JobStatus.assigned, JobStatus.cancelled), isTrue);
      expect(isValidTransition(JobStatus.enRoute, JobStatus.cancelled), isTrue);
      expect(isValidTransition(JobStatus.inProgress, JobStatus.cancelled), isTrue);
    });

    test('backward transitions are rejected', () {
      expect(isValidTransition(JobStatus.assigned, JobStatus.pending), isFalse);
      expect(isValidTransition(JobStatus.enRoute, JobStatus.assigned), isFalse);
      expect(isValidTransition(JobStatus.inProgress, JobStatus.enRoute), isFalse);
      expect(isValidTransition(JobStatus.completed, JobStatus.inProgress), isFalse);
    });

    test('no transitions from terminal states', () {
      expect(isValidTransition(JobStatus.completed, JobStatus.cancelled), isFalse);
      expect(isValidTransition(JobStatus.cancelled, JobStatus.pending), isFalse);
    });

    test('skipping states is rejected', () {
      expect(isValidTransition(JobStatus.pending, JobStatus.enRoute), isFalse);
      expect(isValidTransition(JobStatus.pending, JobStatus.completed), isFalse);
    });
  });

  // ── Tests that use handleMessageForTest directly (synchronous) ──────────────

  group('statusHistory is append-only', () {
    test('3 valid messages produce 3 history entries in order', () {
      final provider = FakeTrackingProvider();
      provider.startTracking('job-1', 'token');

      // Use handleMessageForTest directly for synchronous execution.
      provider.handleMessageForTest(jsonEncode(_statusMsg('pending')));
      provider.handleMessageForTest(jsonEncode(_statusMsg('assigned')));
      provider.handleMessageForTest(jsonEncode(_statusMsg('en_route')));

      expect(provider.statusHistory.length, 3);
      expect(provider.statusHistory[0].status, JobStatus.pending);
      expect(provider.statusHistory[1].status, JobStatus.assigned);
      expect(provider.statusHistory[2].status, JobStatus.enRoute);
    });

    test('history only grows — never shrinks', () {
      final provider = FakeTrackingProvider();
      provider.startTracking('job-2', 'token');

      provider.handleMessageForTest(jsonEncode(_statusMsg('pending')));
      final lengthAfterOne = provider.statusHistory.length;

      provider.handleMessageForTest(jsonEncode(_statusMsg('assigned')));
      final lengthAfterTwo = provider.statusHistory.length;

      expect(lengthAfterTwo, greaterThan(lengthAfterOne));
    });
  });

  group('backward status message is ignored', () {
    test('sending pending after assigned does not change status or history', () {
      final provider = FakeTrackingProvider();
      provider.startTracking('job-3', 'token');

      provider.handleMessageForTest(jsonEncode(_statusMsg('pending')));
      provider.handleMessageForTest(jsonEncode(_statusMsg('assigned')));

      final historyLengthBefore = provider.statusHistory.length;
      final statusBefore = provider.jobStatus;

      // Attempt backward transition
      provider.handleMessageForTest(jsonEncode(_statusMsg('pending')));

      expect(provider.jobStatus, statusBefore);
      expect(provider.statusHistory.length, historyLengthBefore);
    });

    test('unknown status string is ignored', () {
      final provider = FakeTrackingProvider();
      provider.startTracking('job-4', 'token');

      provider.handleMessageForTest(jsonEncode(_statusMsg('pending')));
      final lengthBefore = provider.statusHistory.length;

      provider.handleMessageForTest(jsonEncode(_statusMsg('unknown_status')));

      expect(provider.statusHistory.length, lengthBefore);
      expect(provider.jobStatus, JobStatus.pending);
    });
  });

  group('location updates', () {
    test('worker lat/lng are updated from message', () {
      final provider = FakeTrackingProvider();
      provider.startTracking('job-5', 'token');

      provider.handleMessageForTest(
          jsonEncode(_locationMsg('pending', 6.5244, 3.3792)));

      expect(provider.workerLat, closeTo(6.5244, 0.0001));
      expect(provider.workerLng, closeTo(3.3792, 0.0001));
    });
  });

  group('stopTracking sets isConnected to false', () {
    test('isConnected is false after stopTracking', () {
      final provider = FakeTrackingProvider();
      provider.startTracking('job-6', 'token');

      expect(provider.isConnected, isTrue);

      provider.stopTracking();

      expect(provider.isConnected, isFalse);
    });

    test('stopTracking is idempotent', () {
      final provider = FakeTrackingProvider();
      provider.startTracking('job-7', 'token');
      provider.stopTracking();
      provider.stopTracking(); // second call should not throw
      expect(provider.isConnected, isFalse);
    });
  });

  group('reconnect logic', () {
    test('provider stays connected after a valid message', () {
      final provider = FakeTrackingProvider();
      provider.startTracking('job-8', 'token');

      provider.handleMessageForTest(jsonEncode(_statusMsg('pending')));

      expect(provider.isConnected, isTrue);
      expect(provider.statusHistory.length, 1);
    });

    test('isConnected is false while reconnecting (stream closed)', () async {
      final provider = FakeTrackingProvider();
      provider.startTracking('job-9', 'token');

      expect(provider.isConnected, isTrue);

      provider.closeStream();

      // Allow microtasks to process the onDone callback.
      await Future<void>.delayed(Duration.zero);

      expect(provider.isConnected, isFalse);
    });
  });

  group('terminal state handling', () {
    test('isConnected becomes false when completed status received', () {
      final provider = FakeTrackingProvider();
      provider.startTracking('job-10', 'token');

      provider.handleMessageForTest(jsonEncode(_statusMsg('pending')));
      provider.handleMessageForTest(jsonEncode(_statusMsg('assigned')));
      provider.handleMessageForTest(jsonEncode(_statusMsg('en_route')));
      provider.handleMessageForTest(jsonEncode(_statusMsg('in_progress')));
      provider.handleMessageForTest(jsonEncode(_statusMsg('completed')));

      expect(provider.jobStatus, JobStatus.completed);
      expect(provider.isConnected, isFalse);
    });

    test('no further status changes after completed', () {
      final provider = FakeTrackingProvider();
      provider.startTracking('job-11', 'token');

      provider.handleMessageForTest(jsonEncode(_statusMsg('pending')));
      provider.handleMessageForTest(jsonEncode(_statusMsg('assigned')));
      provider.handleMessageForTest(jsonEncode(_statusMsg('en_route')));
      provider.handleMessageForTest(jsonEncode(_statusMsg('in_progress')));
      provider.handleMessageForTest(jsonEncode(_statusMsg('completed')));

      final historyLength = provider.statusHistory.length;

      // Backward transition after terminal state — must be ignored.
      provider.handleMessageForTest(jsonEncode(_statusMsg('pending')));

      expect(provider.statusHistory.length, historyLength);
    });
  });
}
