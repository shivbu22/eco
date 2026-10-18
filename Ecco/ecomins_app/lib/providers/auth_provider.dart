import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unauthenticated;
  UserModel? _currentUser;
  String? _errorMessage;
  bool _isGuest = false;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isGuest => _isGuest;

  /// Convenience getter for screens that need a simple Map
  Map<String, dynamic>? get user {
    if (_currentUser == null) return null;
    return {
      'uid': _currentUser!.uid,
      'name': _currentUser!.name,
      'email': _currentUser!.email,
      'phone': _currentUser!.phone,
      'tier': _currentUser!.tier,
      'ecoPoints': _currentUser!.ecoPoints,
    };
  }

  AuthProvider() {
    _checkPersistence();
  }

  Future<void> _checkPersistence() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // For demo purposes, start as unauthenticated
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    _isGuest = false;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    if (email.contains('@') && password.length >= 6) {
      _currentUser = UserModel(
        uid: 'demo_user_123',
        name: email.split('@')[0].replaceAll('.', ' '),
        email: email,
        phone: '+91 98765 43210',
        ecoPoints: 1250,
        totalCo2Saved: 18.4,
        totalBookings: 12,
        treesEquivalent: 3,
        tier: 'Eco Pro',
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _status = AuthStatus.error;
      _errorMessage = 'Invalid email or password (min 6 chars)';
      notifyListeners();
      return false;
    }
  }

  Future<void> signInAsGuest() async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _isGuest = true;
    _currentUser = UserModel(
      uid: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Guest User',
      tier: 'Explorer',
    );
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _currentUser = null;
    _isGuest = false;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
