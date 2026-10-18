import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/repositories/eco_repository.dart';

/// A presentation state manager (OSI Layer 6) keeping track of user profile data
/// by subscribing to live streams from EcoRepository.
class UserStateProvider extends ChangeNotifier {
  String _userName = 'Aarav Sharma';
  double _walletBalance = 540.0;
  StreamSubscription<Map<String, dynamic>>? _statsSubscription;

  String get userName => _userName;
  double get walletBalance => _walletBalance;

  UserStateProvider() {
    _initStatsStream();
  }

  void _initStatsStream() {
    _statsSubscription?.cancel();
    _statsSubscription = EcoRepository().watchUserStats('mock_user_123').listen((stats) {
      if (stats.containsKey('walletBalance')) {
        _walletBalance = (stats['walletBalance'] as num).toDouble();
      }
      notifyListeners();
    });
  }

  void updateWallet(double amount) {
    _walletBalance += amount;
    notifyListeners();
  }

  void updateName(String name) {
    _userName = name;
    notifyListeners();
  }

  @override
  void dispose() {
    _statsSubscription?.cancel();
    super.dispose();
  }
}
