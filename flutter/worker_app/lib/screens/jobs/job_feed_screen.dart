import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';
import 'job_detail_screen.dart';

class JobFeedScreen extends StatefulWidget {
  const JobFeedScreen({super.key});

  @override
  State<JobFeedScreen> createState() => _JobFeedScreenState();
}

class _JobFeedScreenState extends State<JobFeedScreen> {
  List<dynamic> _jobs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final token = context.read<WorkerProvider>().token;
      final res = await http.get(
        Uri.parse('http://10.0.2.2:3002/jobs?status=pending'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        setState(() => _jobs = jsonDecode(res.body) as List<dynamic>);
      }
    } catch (_) {
      // show empty state
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No jobs available', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
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
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.work, color: Color(0xFF1565C0)),
              ),
              title: Text(job['service_type'] as String? ?? ''),
              subtitle: Text(
                  job['location']?['address'] as String? ?? 'No address'),
              trailing: Text(
                '₦${job['price'] ?? 0}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => JobDetailScreen(job: job)),
              ),
            ),
          );
        },
      ),
    );
  }
}
