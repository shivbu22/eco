import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _phone;

  bool get isLoggedIn => _token != null;
  String? get token => _token;
  String? get phone => _phone;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _phone = prefs.getString('phone');
    notifyListeners();
  }

  Future<void> requestOtp(String phone) async {
    await ApiService.requestOtp(phone);
  }

  Future<void> verifyOtp(String phone, String otp) async {
    final token = await ApiService.verifyOtp(phone, otp);
    _token = token;
    _phone = phone;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('phone', phone);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _phone = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('phone');
    notifyListeners();
  }
}
