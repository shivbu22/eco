import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _jobs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final token = context.read<AuthProvider>().token!;
      final jobs = await ApiService.getJobs(token, 'cust-demo');
      setState(() => _jobs = jobs);
    } catch (_) {
      // show empty state
    } finally {
      setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed': return Colors.green;
      case 'in_progress': return Colors.blue;
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_jobs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No orders yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _jobs.length,
        itemBuilder: (context, i) {
          final job = _jobs[i] as Map<String, dynamic>;
          final status = job['status'] as String? ?? 'pending';
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _statusColor(status).withOpacity(0.15),
                child: Icon(Icons.cleaning_services,
                    color: _statusColor(status)),
              ),
              title: Text(job['service_type'] as String? ?? ''),
              subtitle: Text(job['location']?['address'] as String? ?? ''),
              trailing: Chip(
                label: Text(status,
                    style: const TextStyle(fontSize: 11, color: Colors.white)),
                backgroundColor: _statusColor(status),
                padding: EdgeInsets.zero,
              ),
            ),
          );
        },
      ),
    );
  }
}
