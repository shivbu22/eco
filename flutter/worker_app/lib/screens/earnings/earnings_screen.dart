import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  Map<String, dynamic>? _earnings;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final provider = context.read<WorkerProvider>();
      final workerId = provider.workerId ?? 'worker-demo';
      final token = provider.token;
      final res = await http.get(
        Uri.parse('http://10.0.2.2:3006/earnings/$workerId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        setState(() => _earnings = jsonDecode(res.body) as Map<String, dynamic>);
      }
    } catch (_) {
      // show zero state
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final today = _earnings?['today'] ?? 0;
    final week = _earnings?['week'] ?? 0;
    final allTime = _earnings?['all_time'] ?? 0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _EarningsCard(label: 'Today', amount: today, color: const Color(0xFF1565C0)),
          const SizedBox(height: 12),
          _EarningsCard(label: 'This Week', amount: week, color: const Color(0xFF6A1B9A)),
          const SizedBox(height: 12),
          _EarningsCard(label: 'All Time', amount: allTime, color: const Color(0xFF2E7D32)),
        ],
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final String label;
  final dynamic amount;
  final Color color;

  const _EarningsCard(
      {required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(Icons.account_balance_wallet, color: color),
        ),
        title: Text(label),
        trailing: Text(
          '₦$amount',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }
}
