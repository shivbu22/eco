import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Set to true to skip Firebase and use a mock OTP (any 6 digits work).
/// Flip to false once google-services.json is configured.
const bool kDevMode = true;

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;
  String? _phone;
  String? _token; // used in dev mode only
  String? customerName;
  String? customerAddress;
  bool _isLoading = true;

  bool get isLoggedIn => kDevMode ? _token != null : _auth.currentUser != null;
  bool get isLoading => _isLoading;
  String? get phone => _phone ?? (kDevMode ? null : _auth.currentUser?.phoneNumber);
  String get customerId => kDevMode
      ? (_phone ?? 'cust-demo')
      : (_auth.currentUser?.uid ?? 'cust-demo');
  bool get hasProfile =>
      customerName != null &&
      customerName!.isNotEmpty &&
      customerAddress != null &&
      customerAddress!.isNotEmpty;

  /// Returns the current token (Firebase ID token in prod, dev token in dev mode).
  Future<String?> get token async {
    if (kDevMode) return _token;
    return _auth.currentUser?.getIdToken();
  }

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    // Restore profile from SharedPreferences
    final p = await SharedPreferences.getInstance();
    customerName = p.getString('customerName');
    customerAddress = p.getString('customerAddress');
    _phone = p.getString('phone');

    if (kDevMode) {
      _token = p.getString('token');
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Listen to Firebase auth state — fires immediately with current user
    _auth.authStateChanges().listen((user) {
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Step 1: Send OTP via Firebase Phone Auth (or mock in dev mode).
  Future<void> requestOtp(String phone) async {
    _phone = phone;

    if (kDevMode) {
      // Dev mode: no real SMS — any 6-digit code will work in verifyOtp
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }

    final completer = Completer<void>();
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval on Android — sign in immediately
        await _auth.signInWithCredential(credential);
        notifyListeners();
        if (!completer.isCompleted) completer.complete();
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(e.message ?? 'Verification failed');
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );

    return completer.future;
  }

  /// Step 2: Verify the 6-digit OTP (mock in dev mode — any code works).
  Future<void> verifyOtp(String phone, String otp) async {
    if (kDevMode) {
      // Dev mode: accept any 6-digit code, store a fake token
      _token = 'dev-token-${phone.replaceAll('+', '')}';
      final p = await SharedPreferences.getInstance();
      await p.setString('token', _token!);
      await p.setString('phone', phone);
      notifyListeners();
      return;
    }

    if (_verificationId == null) throw Exception('No verification in progress');
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );
    await _auth.signInWithCredential(credential);
    final p = await SharedPreferences.getInstance();
    await p.setString('phone', phone);
    notifyListeners();
  }

  Future<void> saveProfile(String name, String address) async {
    customerName = name;
    customerAddress = address;
    final p = await SharedPreferences.getInstance();
    await p.setString('customerName', name);
    await p.setString('customerAddress', address);
    notifyListeners();
  }

  Future<void> logout() async {
    if (!kDevMode) await _auth.signOut();
    _token = null;
    customerName = null;
    customerAddress = null;
    _phone = null;
    _verificationId = null;
    final p = await SharedPreferences.getInstance();
    await p.remove('token');
    await p.remove('phone');
    await p.remove('customerName');
    await p.remove('customerAddress');
    notifyListeners();
  }
}
