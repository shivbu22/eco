import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/constants.dart';

// ── Job status enum ──────────────────────────────────────────────────────────

enum JobStatus {
  pending,
  assigned,
  enRoute,
  inProgress,
  completed,
  cancelled;

  /// Maps backend snake_case strings to [JobStatus] values.
  /// Returns null for unknown strings (caller should ignore the message).
  static JobStatus? fromString(String s) {
    switch (s) {
      case 'pending':
        return JobStatus.pending;
      case 'assigned':
        return JobStatus.assigned;
      case 'en_route':
        return JobStatus.enRoute;
      case 'in_progress':
        return JobStatus.inProgress;
      case 'completed':
        return JobStatus.completed;
      case 'cancelled':
        return JobStatus.cancelled;
      default:
        return null;
    }
  }
}

// ── Valid forward-only transition map ────────────────────────────────────────

const Map<JobStatus, Set<JobStatus>> _validTransitions = {
  JobStatus.pending:    {JobStatus.assigned, JobStatus.cancelled},
  JobStatus.assigned:   {JobStatus.enRoute, JobStatus.cancelled},
  JobStatus.enRoute:    {JobStatus.inProgress, JobStatus.cancelled},
  JobStatus.inProgress: {JobStatus.completed, JobStatus.cancelled},
  JobStatus.completed:  <JobStatus>{},
  JobStatus.cancelled:  <JobStatus>{},
};

/// Returns true when transitioning from [current] to [next] is valid.
/// A null [current] means the job has not started yet; any non-null [next]
/// that is [JobStatus.pending] is accepted as the initial state.
bool isValidTransition(JobStatus? current, JobStatus next) {
  if (current == null) return next == JobStatus.pending;
  return _validTransitions[current]?.contains(next) ?? false;
}

// ── StatusEvent ──────────────────────────────────────────────────────────────

class StatusEvent {
  const StatusEvent({
    required this.status,
    required this.timestamp,
    required this.label,
  });

  final JobStatus status;
  final DateTime timestamp;
  final String label;
}

// ── TrackingProvider ─────────────────────────────────────────────────────────

class TrackingProvider extends ChangeNotifier {
  String? jobId;
  JobStatus? jobStatus;
  double? workerLat;
  double? workerLng;
  List<StatusEvent> statusHistory = [];
  bool isConnected = false;

  int _reconnectAttempts = 0;
  StreamSubscription<dynamic>? _sub;
  WebSocketChannel? _channel;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Connects to the tracking WebSocket for [jobId].
  /// Cancels any existing subscription before opening a new one.
  void startTracking(String jobId, String token) {
    stopTracking();

    this.jobId = jobId;

    final uri = Uri.parse(
      '${AppConstants.trackingWsUrlAndroid}/track/job/$jobId',
    );

    _channel = WebSocketChannel.connect(uri);
    isConnected = true;
    notifyListeners();

    _sub = _channel!.stream.listen(
      (data) {
        _reconnectAttempts = 0; // reset on successful message
        _handleMessage(data);
      },
      onError: (Object _) {
        isConnected = false;
        notifyListeners();
        _scheduleReconnect(jobId, token);
      },
      onDone: () {
        // Only reconnect if the job is not yet terminal.
        if (jobStatus != JobStatus.completed &&
            jobStatus != JobStatus.cancelled) {
          isConnected = false;
          notifyListeners();
          _scheduleReconnect(jobId, token);
        }
      },
      cancelOnError: true,
    );
  }

  /// Cancels the active subscription and closes the WebSocket channel.
  void stopTracking() {
    _sub?.cancel();
    _sub = null;
    _channel?.sink.close();
    _channel = null;
    isConnected = false;
    notifyListeners();
  }

  // ── Message handling ───────────────────────────────────────────────────────

  void _handleMessage(dynamic data) {
    Map<String, dynamic> event;
    try {
      event = jsonDecode(data as String) as Map<String, dynamic>;
    } catch (_) {
      return; // ignore malformed messages
    }

    bool changed = false;

    // Status update
    final rawStatus = event['status'] as String?;
    if (rawStatus != null) {
      final newStatus = JobStatus.fromString(rawStatus);
      if (newStatus != null && isValidTransition(jobStatus, newStatus)) {
        jobStatus = newStatus;
        statusHistory = List.unmodifiable([
          ...statusHistory,
          StatusEvent(
            status: newStatus,
            timestamp: DateTime.now(),
            label: _labelFor(newStatus),
          ),
        ]);
        changed = true;
      }
    }

    // Worker location update
    final worker = event['worker'] as Map<String, dynamic>?;
    if (worker != null) {
      final lat = (worker['lat'] as num?)?.toDouble();
      final lng = (worker['lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        workerLat = lat;
        workerLng = lng;
        changed = true;
      }
    }

    if (changed) notifyListeners();

    // Close connection on terminal states
    if (jobStatus == JobStatus.completed ||
        jobStatus == JobStatus.cancelled) {
      _sub?.cancel();
      _sub = null;
      _channel?.sink.close();
      _channel = null;
      isConnected = false;
      notifyListeners();
    }
  }

  // ── Reconnect logic ────────────────────────────────────────────────────────

  void _scheduleReconnect(String jobId, String token) {
    if (_reconnectAttempts >= AppConstants.wsReconnectMaxAttempts) return;

    _reconnectAttempts++;
    isConnected = false;
    notifyListeners();

    Future.delayed(AppConstants.wsReconnectDelay, () {
      // Guard: don't reconnect if tracking was explicitly stopped or terminal.
      if (jobStatus == JobStatus.completed ||
          jobStatus == JobStatus.cancelled) {
        return;
      }
      startTracking(jobId, token);
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _labelFor(JobStatus status) {
    switch (status) {
      case JobStatus.pending:
        return 'Waiting for worker';
      case JobStatus.assigned:
        return 'Worker assigned';
      case JobStatus.enRoute:
        return 'Worker on the way';
      case JobStatus.inProgress:
        return 'Service in progress';
      case JobStatus.completed:
        return 'Service completed';
      case JobStatus.cancelled:
        return 'Cancelled';
    }
  }

  // ── Testing hook ───────────────────────────────────────────────────────────

  /// Exposes [_handleMessage] for unit testing without a real WebSocket.
  @visibleForTesting
  void handleMessageForTest(dynamic data) => _handleMessage(data);

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
