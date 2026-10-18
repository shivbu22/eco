import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const _authBase = 'http://10.0.2.2:3001';
const _workerBase = 'http://10.0.2.2:3003';

class WorkerProvider extends ChangeNotifier {
  String? _token;
  String? _workerId;
  bool _available = true;
  List<dynamic> _jobs = [];

  bool get isLoggedIn => _token != null;
  String? get token => _token;
  String? get workerId => _workerId;
  bool get available => _available;
  List<dynamic> get jobs => _jobs;

  WorkerProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('worker_token');
    _workerId = prefs.getString('worker_id');
    notifyListeners();
  }

  Future<void> requestOtp(String phone) async {
    await http.post(Uri.parse('$_authBase/auth/request-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}));
  }

  Future<void> verifyOtp(String phone, String otp) async {
    final res = await http.post(Uri.parse('$_authBase/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp}));
    final data = jsonDecode(res.body);
    _token = data['token'] as String;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('worker_token', _token!);
    notifyListeners();
  }

  Future<void> toggleAvailability() async {
    _available = !_available;
    if (_workerId != null) {
      await http.patch(
        Uri.parse('$_workerBase/workers/$_workerId/availability'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'available': _available}),
      );
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _workerId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('worker_token');
    await prefs.remove('worker_id');
    notifyListeners();
  }
}
