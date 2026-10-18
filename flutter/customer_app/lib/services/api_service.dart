import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this to your backend base URL
  static const String baseUrl = 'http://10.0.2.2:3001'; // Android emulator → localhost
  // static const String baseUrl = 'http://localhost:3001'; // Web / iOS simulator

  static Map<String, String> _headers({String? token}) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // ── Auth ──────────────────────────────────────────────────────────────────

  static Future<void> requestOtp(String phone) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/request-otp'),
      headers: _headers(),
      body: jsonEncode({'phone': phone}),
    );
    _check(res);
  }

  static Future<String> verifyOtp(String phone, String otp) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: _headers(),
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );
    _check(res);
    return jsonDecode(res.body)['token'] as String;
  }

  // ── Jobs ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createJob({
    required String token,
    required String serviceType,
    required double lat,
    required double lng,
    required String address,
    required String zoneId,
    required String customerId,
    required double price,
  }) async {
    final res = await http.post(
      Uri.parse('http://10.0.2.2:3002/jobs'),
      headers: _headers(token: token),
      body: jsonEncode({
        'service_type': serviceType,
        'location': {'lat': lat, 'lng': lng, 'address': address},
        'zone_id': zoneId,
        'customer_id': customerId,
        'price': price,
      }),
    );
    _check(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getJobs(String token, String customerId) async {
    final res = await http.get(
      Uri.parse('http://10.0.2.2:3002/jobs?customer_id=$customerId'),
      headers: _headers(token: token),
    );
    _check(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  // ── Rewards ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getRewards(
      String token, String customerId) async {
    final res = await http.get(
      Uri.parse('http://10.0.2.2:3005/rewards/$customerId'),
      headers: _headers(token: token),
    );
    _check(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ── Pricing ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getPrice(
      String serviceType, String zoneId) async {
    final res = await http.get(
      Uri.parse('http://10.0.2.2:3004/pricing/$serviceType/$zoneId'),
    );
    _check(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static void _check(http.Response res) {
    if (res.statusCode >= 400) {
      final body = jsonDecode(res.body);
      final msg = body['error']?['message'] ?? 'Request failed (${res.statusCode})';
      throw Exception(msg);
    }
  }
}
