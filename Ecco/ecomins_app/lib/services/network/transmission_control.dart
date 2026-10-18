import 'dart:async';
import 'dart:math';
import 'network_client.dart';

/// A senior-grade Transport Layer manager mimicking TCP transmission reliability,
/// flow control, sliding window status, and exponential backoff retry algorithms.
class TransmissionControlManager {
  static final TransmissionControlManager _instance = TransmissionControlManager._internal();
  factory TransmissionControlManager() => _instance;
  TransmissionControlManager._internal();

  final SimulatedNetworkClient _networkClient = SimulatedNetworkClient();
  final Random _random = Random();

  /// Executes a fully reliable transmission modeled on the TCP/IP stack.
  /// Includes connection handshake, segment flow control, and exponential backoff on drop.
  Future<Map<String, dynamic>> transmit(String endpoint, Map<String, dynamic> payload) async {
    final int clientPort = _random.nextInt(16384) + 49152;
    final int serverPort = 443;
    final int initialSeq = _random.nextInt(5000) + 1;
    
    _networkClient.logEvent("[TRANSPORT] --- Initiating TCP Handshake (3-Way) ---");
    
    // 1. TCP 3-Way Handshake Simulation
    try {
      await _executeHandshake(clientPort, serverPort, initialSeq);
    } catch (e) {
      _networkClient.logEvent("[TRANSPORT] [ERROR] Handshake failed. Network host unreachable.");
      rethrow;
    }

    _networkClient.logEvent("[TRANSPORT] Connection Established. Starting data transmission...");
    
    // 2. Transmit segments with Sliding Window Flow Control & Exponential Backoff
    int attempt = 0;
    const int maxAttempts = 4;
    int backoffSeconds = 1;

    while (attempt < maxAttempts) {
      attempt++;
      final int currentSeq = initialSeq + 1 + (attempt * 100);
      _networkClient.logEvent("[TRANSPORT] [TX] Sending Data. Seq=$currentSeq, Ack=${initialSeq + 1}, Win=4096B");

      try {
        // Send down to physical/network layers
        final response = await _networkClient.sendRequest(endpoint, payload);
        
        // Successful transmission! Send ACK back.
        _networkClient.logEvent("[TRANSPORT] [RX] Received ACK for Seq=$currentSeq. Transmission Completed.");
        _networkClient.logEvent("[TRANSPORT] --- TCP Connection Closed gracefully (FIN) ---");
        return response;
      } catch (e) {
        _networkClient.logEvent("[TRANSPORT] [WARN] Segment drop detected for Seq=$currentSeq on Attempt $attempt.");
        
        if (attempt >= maxAttempts) {
          _networkClient.logEvent("[TRANSPORT] [FATAL] Retransmission counter exceeded. Connection timed out.");
          throw TimeoutException("Transport layer transmission failed after $maxAttempts attempts due to severe packet loss.");
        }

        // Apply Exponential Backoff
        _networkClient.logEvent("[TRANSPORT] Retrying. Backoff time: ${backoffSeconds}s... (Exponential Retransmission Timer)");
        await Future.delayed(Duration(seconds: backoffSeconds));
        backoffSeconds *= 2; // Exponential increase
      }
    }

    throw TimeoutException("Transport layer transmission failed.");
  }

  /// Simulates TCP Three-Way Handshake
  Future<void> _executeHandshake(int clientPort, int serverPort, int clientSeq) async {
    // 1. SYN
    _networkClient.logEvent("[TRANSPORT] [SYN] client:$clientPort -> server:$serverPort. Seq=$clientSeq");
    await Future.delayed(const Duration(milliseconds: 100));

    // 2. SYN-ACK
    final int serverSeq = _random.nextInt(5000) + 1;
    _networkClient.logEvent("[TRANSPORT] [SYN-ACK] server:$serverPort -> client:$clientPort. Seq=$serverSeq, Ack=${clientSeq + 1}");
    await Future.delayed(const Duration(milliseconds: 100));

    // 3. ACK
    _networkClient.logEvent("[TRANSPORT] [ACK] client:$clientPort -> server:$serverPort. Seq=${clientSeq + 1}, Ack=${serverSeq + 1}");
    await Future.delayed(const Duration(milliseconds: 50));
  }
}
