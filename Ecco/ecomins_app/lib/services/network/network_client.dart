import 'dart:async';
import 'dart:math';

/// A senior-engineered Network Client simulating OSI Physical (signal latency),
/// Data Link (frame integrity), and Network (routing/drop) layers.
class SimulatedNetworkClient {
  static final SimulatedNetworkClient _instance = SimulatedNetworkClient._internal();
  factory SimulatedNetworkClient() => _instance;
  SimulatedNetworkClient._internal();

  // Simulated Network Properties
  double _packetDropRate = 0.15; // 15% default packet loss rate
  int _latencyMs = 400; // 400ms default latency

  double get packetDropRate => _packetDropRate;
  int get latencyMs => _latencyMs;

  set packetDropRate(double rate) {
    _packetDropRate = rate.clamp(0.0, 1.0);
    _logStreamController.add("[PHYSICAL] Packet loss rate set to ${(_packetDropRate * 100).toStringAsFixed(0)}%");
  }

  set latencyMs(int ms) {
    _latencyMs = ms.clamp(0, 5000);
    _logStreamController.add("[PHYSICAL] Latency set to ${_latencyMs}ms");
  }

  // Live packet log stream for the UI Terminal
  final StreamController<String> _logStreamController = StreamController<String>.broadcast();
  Stream<String> get logs => _logStreamController.stream;

  final Random _random = Random();

  /// Logs a packet/frame transmission event
  void logEvent(String message) {
    _logStreamController.add(message);
  }

  /// Sends a simulated HTTP/TCP frame across the physical medium
  Future<Map<String, dynamic>> sendRequest(String endpoint, Map<String, dynamic> payload) async {
    final int seqNum = _random.nextInt(10000) + 1000;
    
    logEvent("[PHYSICAL] [TX] Segment: Seq=$seqNum, len=${payload.toString().length}B -> $endpoint");
    logEvent("[DATA LINK] Frame structured. MAC Source: 48:3B:38:A2:BC:10 -> Dest: Gateway");
    
    // 1. Simulate Latency (Physical signal propagation)
    if (_latencyMs > 0) {
      logEvent("[PHYSICAL] Signal propagating. Delaying ${_latencyMs}ms...");
      await Future.delayed(Duration(milliseconds: _latencyMs));
    }

    // 2. Simulate Packet Drops (Network routing drops)
    final double roll = _random.nextDouble();
    if (roll < _packetDropRate) {
      logEvent("[NETWORK] [DROP] Packet drop occurred! Segment Seq=$seqNum failed to route.");
      throw TimeoutException("Network routing timeout. Packet dropped at Layer 3.");
    }

    logEvent("[NETWORK] [ROUTED] Segment Seq=$seqNum reached destination server successfully.");
    logEvent("[APPLICATION] Payload parsed. Status: 200 OK");
    
    return {
      'status': 200,
      'endpoint': endpoint,
      'seqNum': seqNum,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
