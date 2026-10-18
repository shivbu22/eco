import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// For web, use localhost directly
const _bookingBase = 'http://localhost:3002';
const _workerBase  = 'http://localhost:3003';
const _analyticsBase = 'http://localhost:3007';

class AdminProvider extends ChangeNotifier {
  List<dynamic> jobs = [];
  List<dynamic> workers = [];
  Map<String, dynamic> analytics = {};
  bool loadingJobs = false;
  bool loadingWorkers = false;

  // ── Jobs ──────────────────────────────────────────────────────────────────

  Future<void> loadJobs({String? status}) async {
    loadingJobs = true;
    notifyListeners();
    try {
      final url = status != null
          ? '$_bookingBase/jobs?status=$status'
          : '$_bookingBase/jobs';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        jobs = jsonDecode(res.body) as List<dynamic>;
      }
    } catch (_) {}
    loadingJobs = false;
    notifyListeners();
  }

  Future<void> updateJobStatus(
      String jobId, String status, String reason) async {
    await http.patch(
      Uri.parse('$_bookingBase/jobs/$jobId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status, 'reason': reason}),
    );
    await loadJobs();
  }

  // ── Workers ───────────────────────────────────────────────────────────────

  Future<void> loadWorkers() async {
    loadingWorkers = true;
    notifyListeners();
    try {
      final res = await http.get(Uri.parse('$_workerBase/workers'));
      if (res.statusCode == 200) {
        workers = jsonDecode(res.body) as List<dynamic>;
      }
    } catch (_) {}
    loadingWorkers = false;
    notifyListeners();
  }

  Future<void> approveKyc(String workerId) async {
    await http.patch(
      Uri.parse('$_workerBase/workers/$workerId/kyc/review'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'approved': true}),
    );
    await loadWorkers();
  }

  Future<void> rejectKyc(String workerId, String reason) async {
    await http.patch(
      Uri.parse('$_workerBase/workers/$workerId/kyc/review'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'approved': false, 'reason': reason}),
    );
    await loadWorkers();
  }

  // ── Analytics ─────────────────────────────────────────────────────────────

  Future<void> loadAnalytics() async {
    try {
      final res = await http.get(Uri.parse('$_analyticsBase/analytics/summary'));
      if (res.statusCode == 200) {
        analytics = jsonDecode(res.body) as Map<String, dynamic>;
        notifyListeners();
      }
    } catch (_) {}
  }
}
