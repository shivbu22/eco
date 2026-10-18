import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/pricing_result.dart';

/// Backend URL configuration.
///
/// Set [useFirebase] to true to route booking/rewards/tracking through
/// Firebase Cloud Functions (emulator or production).
/// Auth and pricing still use the local Node.js services.
///
/// Firebase emulator base: http://10.0.2.2:5001/<project-id>/us-central1
/// Replace 'ecomins-app' with your actual Firebase project ID.
class Api {
  // ── Toggle ────────────────────────────────────────────────────────────────
  static const bool useFirebase = true; // set false to use local Node.js

  // ── Local Node.js services ────────────────────────────────────────────────
  static const _auth    = 'http://10.0.2.2:3001';
  static const _pricing = 'http://10.0.2.2:3004';

  // ── Firebase emulator (Android emulator → 10.0.2.2 = host machine) ───────
  static const _fbBase  = 'http://10.0.2.2:5001/ecomins-app/us-central1';

  // ── Resolved URLs ─────────────────────────────────────────────────────────
  static String get _booking => useFirebase ? '$_fbBase/jobs'    : 'http://10.0.2.2:3002';
  static String get _rewards => useFirebase ? '$_fbBase/rewards' : 'http://10.0.2.2:3005';

  static Map<String, String> _h({String? token}) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // ── Auth ──────────────────────────────────────────────────────────────────

  static Future<void> requestOtp(String phone) async {
    final r = await http.post(Uri.parse('$_auth/auth/request-otp'),
        headers: _h(), body: jsonEncode({'phone': phone}));
    _guard(r);
  }

  static Future<String> verifyOtp(String phone, String otp) async {
    final r = await http.post(Uri.parse('$_auth/auth/verify-otp'),
        headers: _h(), body: jsonEncode({'phone': phone, 'otp': otp}));
    _guard(r);
    return jsonDecode(r.body)['token'] as String;
  }

  // ── Pricing ───────────────────────────────────────────────────────────────

  static Future<double> getPrice(String serviceType, String zoneId) async {
    try {
      final r = await http.get(
          Uri.parse('$_pricing/pricing/$serviceType/$zoneId'));
      if (r.statusCode == 200) {
        return ((jsonDecode(r.body)['total'] as num?) ?? 500).toDouble();
      }
    } catch (_) {}
    return 500.0;
  }

  static Future<PricingResult> getPricingResult(
      String serviceType, String zoneId) async {
    try {
      final r = await http
          .get(Uri.parse('$_pricing/pricing/$serviceType/$zoneId'));
      if (r.statusCode == 200) {
        return PricingResult.fromJson(
            jsonDecode(r.body) as Map<String, dynamic>);
      }
    } catch (_) {}
    return const PricingResult(base: 500, tax: 0, surcharge: 0, total: 500);
  }

  // ── Tracking (WebSocket) ──────────────────────────────────────────────────

  static WebSocketChannel connectTracking(String jobId, String token) {
    final uri = Uri.parse('ws://10.0.2.2:3006/track/job/$jobId');
    return WebSocketChannel.connect(uri);
  }

  // ── Jobs ──────────────────────────────────────────────────────────────────

  static Future<String> createJob({
    required String token,
    required String serviceType,
    required String address,
    required String zoneId,
    required String customerId,
    required double price,
  }) async {
    final r = await http.post(Uri.parse('$_booking/jobs'),
        headers: _h(token: token),
        body: jsonEncode({
          'service_type': serviceType,
          'location': {'lat': 6.5244, 'lng': 3.3792, 'address': address},
          'zone_id': zoneId,
          'customer_id': customerId,
          'price': price,
        }));
    _guard(r);
    return jsonDecode(r.body)['job_id'] as String;
  }

  static Future<List<Map<String, dynamic>>> getJobs(
      String token, String customerId) async {
    final r = await http.get(
        Uri.parse('$_booking/jobs?customer_id=$customerId'),
        headers: _h(token: token));
    _guard(r);
    return (jsonDecode(r.body) as List)
        .cast<Map<String, dynamic>>();
  }

  // ── Rewards ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getRewards(
      String token, String customerId) async {
    final r = await http.get(Uri.parse('$_rewards/rewards/$customerId'),
        headers: _h(token: token));
    _guard(r);
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  static Future<void> redeemPoints(
      String token, String customerId, int points) async {
    final r = await http.post(
        Uri.parse('$_rewards/rewards/$customerId/redeem'),
        headers: _h(token: token),
        body: jsonEncode({'points': points}));
    _guard(r);
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  static void _guard(http.Response r) {
    if (r.statusCode >= 400) {
      final body = jsonDecode(r.body);
      throw Exception(
          body['error']?['message'] ?? 'Error ${r.statusCode}');
    }
  }
}
