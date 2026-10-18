import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  Map<String, dynamic>? _rewards;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final token = context.read<AuthProvider>().token!;
      final data = await ApiService.getRewards(token, 'cust-demo');
      setState(() => _rewards = data);
    } catch (_) {
      // show zero state
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final points = _rewards?['points_balance'] ?? 0;
    final ecoScore = _rewards?['eco_score'] ?? 0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Card(
            color: const Color(0xFF2E7D32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.eco, size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  Text('$points',
                      style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const Text('Eco Points',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text('Eco Score'),
              trailing: Text('$ecoScore',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Earn points by booking eco-friendly services',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
