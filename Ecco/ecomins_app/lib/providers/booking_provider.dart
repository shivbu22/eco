import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/booking_model.dart';
import '../data/models/address_model.dart';

class BookingProvider extends ChangeNotifier {
  final List<BookingModel> _bookings = [];
  BookingModel? _activeBooking;
  bool _isLoading = false;
  Timer? _trackingTimer;

  // ─── Getters ──────────────────────────────────────────
  List<BookingModel> get bookings => List.unmodifiable(_bookings);
  BookingModel? get activeBooking => _activeBooking;
  bool get isLoading => _isLoading;
  bool get hasActiveBooking => _activeBooking != null;

  List<BookingModel> get completedBookings =>
      _bookings.where((b) => b.status == BookingStatus.completed).toList();

  List<BookingModel> get activeBookings =>
      _bookings.where((b) => b.isActive).toList();

  BookingModel? get lastCompletedBooking {
    final completed = completedBookings;
    if (completed.isEmpty) return null;
    completed.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return completed.first;
  }

  StreamSubscription<List<BookingModel>>? _bookingsSubscription;

  BookingProvider() {
    _initBookingsStream();
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    _bookingsSubscription?.cancel();
    super.dispose();
  }

  void _initBookingsStream() {
    _isLoading = true;
    _bookingsSubscription?.cancel();

    // Set up mock Address that fits seed files
    const mockAddress = AddressModel(
      id: 'addr_1',
      label: 'Home',
      addressLine1: '14, 2nd Cross, Koramangala',
      city: 'Bengaluru',
      state: 'Karnataka',
      pincode: '560034',
      latitude: 12.9348,
      longitude: 77.6102,
    );

    // Seed initial mock bookings inside the repository first
    final repo = EcoRepository();
    
    // Subscribe to watchBookings stream
    _bookingsSubscription = repo.watchBookings('mock_user_123').listen((bookingsList) {
      _bookings.clear();
      _bookings.addAll(bookingsList);
      
      // If there are no bookings, preload default list
      if (_bookings.isEmpty) {
        repo.createBooking('mock_user_123', BookingModel(
          id: 'b1',
          serviceId: '1',
          serviceName: 'Eco Home Cleaning',
          serviceEmoji: '🧹',
          serviceImage: 'assets/images/eco_cleaning.png',
          userId: 'mock_user_123',
          workerId: 'w1',
          workerName: 'Arjun M.',
          workerRating: 4.9,
          status: BookingStatus.completed,
          scheduledAt: DateTime.now().subtract(const Duration(days: 16)),
          address: mockAddress,
          selectedOption: '2BHK',
          subtotal: 499.0,
          gst: 89.82,
          total: 588.82,
          carbonSaved: 2.4,
          createdAt: DateTime.now().subtract(const Duration(days: 16)),
        ));
      }

      // Check for active booking in standard set
      _activeBooking = _bookings.firstWhere(
        (b) => b.isActive,
        orElse: () => _bookings.first,
      );
      
      if (_activeBooking != null && !_activeBooking!.isActive) {
        _activeBooking = null;
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  // ─── Actions ──────────────────────────────────────────
  Future<BookingModel> createBooking({
    required String serviceId,
    required String serviceName,
    required String serviceEmoji,
    String? serviceImage,
    required String selectedOption,
    required double subtotal,
    required double gst,
    required double total,
    required AddressModel address,
    required DateTime scheduledAt,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    final booking = BookingModel(
      id: 'b${_bookings.length + 1}_${DateTime.now().millisecondsSinceEpoch}',
      serviceId: serviceId,
      serviceName: serviceName,
      serviceEmoji: serviceEmoji,
      serviceImage: serviceImage,
      userId: 'mock_user_123',
      status: BookingStatus.confirmed,
      scheduledAt: scheduledAt,
      address: address,
      selectedOption: selectedOption,
      subtotal: subtotal,
      gst: gst,
      total: total,
      carbonSaved: 2.0 + (subtotal / 500),
      notes: notes,
      etaMinutes: 10,
      createdAt: DateTime.now(),
    );

    // Call EcoRepository which uses Simulated Transport & exponential retry policy
    try {
      await EcoRepository().createBooking('mock_user_123', booking);
      _activeBooking = booking;
      _isLoading = false;
      notifyListeners();
      
      // Simulate worker assignment animation after success
      _simulateWorkerAssignment(booking.id);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    return booking;
  }

  void _simulateWorkerAssignment(String bookingId) {
    Future.delayed(const Duration(seconds: 3), () {
      final idx = _bookings.indexWhere((b) => b.id == bookingId);
      if (idx >= 0) {
        _bookings[idx] = _bookings[idx].copyWith(
          status: BookingStatus.workerAssigned,
          workerId: 'w1',
          workerName: 'Arjun M.',
          workerRating: 4.9,
          etaMinutes: 8,
          workerLatitude: 12.9420,
          workerLongitude: 77.6250,
        );
        if (_activeBooking?.id == bookingId) {
          _activeBooking = _bookings[idx];
        }
        notifyListeners();

        // Simulate en route after 5 more seconds
        Future.delayed(const Duration(seconds: 5), () {
          final idx2 = _bookings.indexWhere((b) => b.id == bookingId);
          if (idx2 >= 0) {
            _bookings[idx2] = _bookings[idx2].copyWith(
              status: BookingStatus.enRoute,
              etaMinutes: 5,
            );
            if (_activeBooking?.id == bookingId) {
              _activeBooking = _bookings[idx2];
              _startTrackingSimulation(bookingId);
            }
            notifyListeners();
          }
        });
      }
    });
  }

  void _startTrackingSimulation(String bookingId) {
    _trackingTimer?.cancel();
    int tickCount = 0;
    
    _trackingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final idx = _bookings.indexWhere((b) => b.id == bookingId);
      if (idx < 0 || _bookings[idx].status != BookingStatus.enRoute) {
        timer.cancel();
        return;
      }

      final booking = _bookings[idx];
      final destLat = booking.address.latitude ?? 12.9348;
      final destLng = booking.address.longitude ?? 77.6102;
      final currentLat = booking.workerLatitude ?? 12.9420;
      final currentLng = booking.workerLongitude ?? 77.6250;

      // Move 10% closer each tick with slight jitter for realism
      final jitterLat = (tickCount % 2 == 0) ? 0.0001 : -0.0001;
      final jitterLng = (tickCount % 3 == 0) ? 0.00015 : -0.00005;
      final nextLat = currentLat + (destLat - currentLat) * 0.10 + jitterLat;
      final nextLng = currentLng + (destLng - currentLng) * 0.10 + jitterLng;

      // Compute remaining distance (rough)
      final dist = ((nextLat - destLat).abs() + (nextLng - destLng).abs());
      final nextEta = (dist * 800).toInt().clamp(1, 15);

      tickCount++;

      _bookings[idx] = booking.copyWith(
        workerLatitude: nextLat,
        workerLongitude: nextLng,
        etaMinutes: nextEta,
      );

      if (_activeBooking?.id == bookingId) {
        _activeBooking = _bookings[idx];
      }

      // Worker has arrived
      if (dist < 0.0008) {
        _bookings[idx] = _bookings[idx].copyWith(
          status: BookingStatus.inProgress,
          etaMinutes: 0,
          workerLatitude: destLat,
          workerLongitude: destLng,
        );
        if (_activeBooking?.id == bookingId) {
          _activeBooking = _bookings[idx];
        }
        timer.cancel();

        // Simulate service completion after 30s
        Future.delayed(const Duration(seconds: 30), () {
          _completeBooking(bookingId);
        });
      }

      notifyListeners();
    });
  }

  /// Mark a booking as completed and clear active tracking
  void _completeBooking(String bookingId) {
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx >= 0 && _bookings[idx].status == BookingStatus.inProgress) {
      _bookings[idx] = _bookings[idx].copyWith(
        status: BookingStatus.completed,
      );
      if (_activeBooking?.id == bookingId) {
        _activeBooking = null;
      }
      notifyListeners();
    }
  }

  void cancelBooking(String bookingId) {
    _trackingTimer?.cancel();
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx >= 0) {
      _bookings[idx] = _bookings[idx].copyWith(status: BookingStatus.cancelled);
      if (_activeBooking?.id == bookingId) {
        _activeBooking = null;
      }
      notifyListeners();
    }
  }
}
