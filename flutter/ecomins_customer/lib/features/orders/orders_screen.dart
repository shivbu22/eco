import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../tracking/tracking_provider.dart';
import '../tracking/tracking_screen.dart';
import 'orders_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final idToken = await auth.token;
      if (idToken != null && mounted) {
        context.read<OrdersProvider>().loadJobs(idToken, auth.customerId);
      }
    });
  }

  Color _statusColor(JobStatus status) {
    switch (status) {
      case JobStatus.completed:
        return Colors.green;
      case JobStatus.inProgress:
        return Colors.blue;
      case JobStatus.cancelled:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(JobStatus status) {
    switch (status) {
      case JobStatus.pending:
        return 'pending';
      case JobStatus.assigned:
        return 'assigned';
      case JobStatus.enRoute:
        return 'en_route';
      case JobStatus.inProgress:
        return 'in_progress';
      case JobStatus.completed:
        return 'completed';
      case JobStatus.cancelled:
        return 'cancelled';
    }
  }

  void _onJobTap(BuildContext context, Job job) async {
    if (!job.isActive) return;
    final auth = context.read<AuthProvider>();
    final idToken = await auth.token ?? '';
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => TrackingProvider(),
          child: TrackingScreen(
            jobId: job.id,
            token: idToken,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>();
    final auth = context.watch<AuthProvider>();

    if (orders.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orders.jobs.isEmpty) {
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
      onRefresh: () async {
        final idToken = await auth.token ?? '';
        return orders.refresh(idToken, auth.customerId);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.jobs.length,
        itemBuilder: (context, i) {
          final job = orders.jobs[i];
          final color = _statusColor(job.status);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              onTap: job.isActive ? () => _onJobTap(context, job) : null,
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(Icons.cleaning_services, color: color),
              ),
              title: Text(job.serviceType),
              subtitle: Text(job.address),
              trailing: Chip(
                label: Text(
                  _statusLabel(job.status),
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
                backgroundColor: color,
                padding: EdgeInsets.zero,
              ),
            ),
          );
        },
      ),
    );
  }
}
