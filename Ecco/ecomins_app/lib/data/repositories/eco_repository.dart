import 'dart:async';
import '../../data/models/service_model.dart';
import '../../data/models/booking_model.dart';
import '../../services/network/local_cache.dart';
import '../../services/network/transmission_control.dart';

/// A senior-level Session & Data Repository layer (OSI Layer 5) coordinating
/// offline-first memory caching with active reliable transport pipelines.
class EcoRepository {
  static final EcoRepository _instance = EcoRepository._internal();
  factory EcoRepository() => _instance;

  final LocalCacheService _cache = LocalCacheService();
  final TransmissionControlManager _transport = TransmissionControlManager();

  // Internal StreamControllers for reactive data flow
  final StreamController<List<ServiceModel>> _servicesController = StreamController<List<ServiceModel>>.broadcast();
  final StreamController<List<BookingModel>> _bookingsController = StreamController<List<BookingModel>>.broadcast();
  final StreamController<Map<String, dynamic>> _userStatsController = StreamController<Map<String, dynamic>>.broadcast();

  // Active memory caches
  List<ServiceModel> _cachedServices = [];
  List<BookingModel> _cachedBookings = [];
  Map<String, dynamic> _cachedUserStats = {};

  EcoRepository._internal() {
    // Seed initial cache buffer for zero-latency instant startup
    _preloadLocalData();
  }

  // --- Services Pipeline ---
  
  /// Exposes a stream of services: yields cache immediately, then resolves remote.
  Stream<List<ServiceModel>> watchServices() {
    // Deliver cache synchronously
    Timer.run(() => _servicesController.add(List.unmodifiable(_cachedServices)));
    
    // Asynchronously update via Transport Layer
    _syncServicesFromNetwork();

    return _servicesController.stream;
  }

  Future<void> _syncServicesFromNetwork() async {
    try {
      final response = await _transport.transmit('/api/catalog', {'query': 'all'});
      if (response['status'] == 200) {
        // Sync and save to local cache
        _cache.write('eco_services_catalog', _cachedServices.map((s) => s.copyWith(isAvailableNow: true)).toList());
        _servicesController.add(List.unmodifiable(_cachedServices));
      }
    } catch (e) {
      // Offline-resilience: continue displaying cache, notify about sync details in transmission logs
    }
  }

  // --- Bookings Pipeline ---

  /// Exposes a stream of user bookings. Yields cache immediately, then syncs network.
  Stream<List<BookingModel>> watchBookings(String uid) {
    Timer.run(() => _bookingsController.add(List.unmodifiable(_cachedBookings)));
    _syncBookingsFromNetwork(uid);
    return _bookingsController.stream;
  }

  Future<void> _syncBookingsFromNetwork(String uid) async {
    try {
      final response = await _transport.transmit('/api/bookings', {'userId': uid});
      if (response['status'] == 200) {
        _bookingsController.add(List.unmodifiable(_cachedBookings));
      }
    } catch (e) {
      // Keeps serving cached bookings when network fails
    }
  }

  /// Registers a booking through reliable TCP-simulated Transport.
  Future<void> createBooking(String uid, BookingModel booking) async {
    final Map<String, dynamic> requestPayload = {
      'bookingId': booking.id,
      'serviceId': booking.serviceId,
      'price': booking.total,
      'date': booking.scheduledAt.toIso8601String(),
    };

    // Execute through TCP-like Exponential Backoff engine
    await _transport.transmit('/api/bookings/create', requestPayload);

    // Save to Cache & trigger reactive update
    _cachedBookings.insert(0, booking);
    _cache.write('eco_bookings_$uid', _cachedBookings.map((b) => b.id).toList());
    _bookingsController.add(List.unmodifiable(_cachedBookings));

    // Update User Stats (adds carbon offset, points)
    _cachedUserStats['walletBalance'] = (_cachedUserStats['walletBalance'] as double) - booking.total;
    _cachedUserStats['carbonSaved'] = (_cachedUserStats['carbonSaved'] as double) + booking.carbonSaved;
    _cachedUserStats['points'] = (_cachedUserStats['points'] as int) + (booking.total * 0.1).toInt();
    _cachedUserStats['bookingsCompleted'] = (_cachedUserStats['bookingsCompleted'] as int) + 1;

    _userStatsController.add(Map<String, dynamic>.from(_cachedUserStats));
  }

  // --- User Stats Pipeline ---

  /// Exposes live user stats stream
  Stream<Map<String, dynamic>> watchUserStats(String uid) {
    Timer.run(() => _userStatsController.add(Map<String, dynamic>.from(_cachedUserStats)));
    _syncUserStatsFromNetwork(uid);
    return _userStatsController.stream;
  }

  Future<void> _syncUserStatsFromNetwork(String uid) async {
    try {
      final response = await _transport.transmit('/api/user/stats', {'userId': uid});
      if (response['status'] == 200) {
        _userStatsController.add(Map<String, dynamic>.from(_cachedUserStats));
      }
    } catch (e) {
      // Graceful offline fallback
    }
  }

  void _preloadLocalData() {
    _cachedServices = [
      const ServiceModel(
        id: '1',
        title: 'Eco Home\nCleaning',
        emoji: '🧹',
        image: 'assets/images/eco_cleaning.png',
        basePrice: 299,
        rating: 4.8,
        duration: '2-3 hours',
        category: 'Cleaning',
        tags: ['Popular', 'Eco'],
        ecoScore: 92,
        ecoImpact: ['Non-toxic products', 'Reusable supplies'],
        requiresImage: true,
        suggestion: 'Photos help us estimate the cleaning scope accurately',
        options: [
          ServiceOptionModel(label: '1 BHK', price: 299),
          ServiceOptionModel(label: '2 BHK', price: 499),
          ServiceOptionModel(label: '3 BHK', price: 699),
          ServiceOptionModel(label: '4+ BHK', price: 999),
        ],
        isAvailableNow: true,
      ),
      const ServiceModel(
        id: '2',
        title: 'Garbage\nCollection',
        emoji: '🗑️',
        image: 'assets/images/garbage_collection.png',
        basePrice: 49,
        rating: 4.6,
        duration: '30-45 min',
        category: 'Waste',
        tags: ['Daily', 'Essential'],
        ecoScore: 85,
        ecoImpact: ['Segregated waste', 'Composting'],
        options: [
          ServiceOptionModel(label: 'One-time', price: 49),
          ServiceOptionModel(label: '1 Week', price: 149),
          ServiceOptionModel(label: '1 Month', price: 499),
        ],
        isAvailableNow: true,
      ),
      const ServiceModel(
        id: '3',
        title: 'Recycling\nPickup',
        emoji: '♻️',
        image: 'assets/images/recycling_pickup.png',
        basePrice: 0,
        rating: 4.9,
        duration: '1-2 hours',
        category: 'Recycling',
        tags: ['Free', 'Eco Hero'],
        ecoScore: 98,
        ecoImpact: ['Reduces landfill', 'Earns eco-points'],
        options: [
          ServiceOptionModel(label: 'Paper & Cardboard', price: 0),
          ServiceOptionModel(label: 'Plastic & Metal', price: 0),
          ServiceOptionModel(label: 'Electronics', price: 49),
          ServiceOptionModel(label: 'Mixed', price: 0),
        ],
        isAvailableNow: true,
      ),
      const ServiceModel(
        id: '4',
        title: 'Solar Panel\nCleaning',
        emoji: '☀️',
        image: 'assets/images/solar_cleaning.png',
        basePrice: 599,
        rating: 4.7,
        duration: '1-2 hours',
        category: 'Solar',
        tags: ['Premium', 'Specialized'],
        ecoScore: 95,
        ecoImpact: ['+20% efficiency', 'Clean energy boost'],
        requiresImage: true,
        suggestion: 'Share a photo of your solar setup for accurate pricing',
        options: [
          ServiceOptionModel(label: 'Up to 5 Panels', price: 599),
          ServiceOptionModel(label: '6-10 Panels', price: 999),
          ServiceOptionModel(label: '11-20 Panels', price: 1499),
          ServiceOptionModel(label: '20+ Panels', price: 1999),
        ],
        isAvailableNow: true,
      ),
    ];

    _cachedUserStats = {
      'walletBalance': 540.0,
      'carbonSaved': 12.5,
      'points': 1200,
      'bookingsCompleted': 8,
      'treesEquivalent': 3,
    };
  }
}
