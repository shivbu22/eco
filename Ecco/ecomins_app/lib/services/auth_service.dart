class AuthService {
  // Mock auth state stream
  Stream<dynamic> get user => Stream.value(null);

  // Mock Sign In Anonymously
  Future<Map<String, dynamic>?> signInAnonymously() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {'uid': 'mock_user_123'};
  }

  // Mock Sign In with Email/Password
  Future<Map<String, dynamic>?> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isNotEmpty && password.length >= 6) {
      return {'uid': 'mock_user_123', 'email': email};
    }
    return null;
  }

  // Mock Logout
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Mock Get current user
  Map<String, dynamic>? get currentUser => null;
}
