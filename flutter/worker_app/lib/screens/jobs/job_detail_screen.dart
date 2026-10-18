import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';

class JobDetailScreen extends StatefulWidget {
  final Map<String, dynamic> job;
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _loading = false;

  Future<void> _startJob() async {
    setState(() => _loading = true);
    try {
      final token = context.read<WorkerProvider>().token;
      final jobId = widget.job['id'] as String;
      final res = await http.post(
        Uri.parse('http://10.0.2.2:3002/jobs/$jobId/start'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(
            {'before_photo_url': 'https://example.com/before.jpg'}),
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job started!')));
        Navigator.pop(context);
      } else {
        final msg = jsonDecode(res.body)['error']?['message'] ?? 'Error';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _completeJob() async {
    setState(() => _loading = true);
    try {
      final token = context.read<WorkerProvider>().token;
      final jobId = widget.job['id'] as String;
      final res = await http.post(
        Uri.parse('http://10.0.2.2:3002/jobs/$jobId/complete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(
            {'after_photo_url': 'https://example.com/after.jpg'}),
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job completed!')));
        Navigator.pop(context);
      } else {
        final msg = jsonDecode(res.body)['error']?['message'] ?? 'Error';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final status = job['status'] as String? ?? 'pending';

    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row('Service', job['service_type'] ?? ''),
                    _row('Address',
                        job['location']?['address'] ?? 'N/A'),
                    _row('Status', status),
                    _row('Price', '₦${job['price'] ?? 0}'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (status == 'pending' || status == 'assigned' || status == 'en_route')
              FilledButton.icon(
                onPressed: _loading ? null : _startJob,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Job'),
              ),
            const SizedBox(height: 12),
            if (status == 'in_progress')
              FilledButton.icon(
                onPressed: _loading ? null : _completeJob,
                icon: const Icon(Icons.check_circle),
                label: const Text('Complete Job'),
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.green),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
                width: 80,
                child: Text(label,
                    style: const TextStyle(color: Colors.grey))),
            Expanded(
                child: Text(value,
                    style:
                        const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
      );
}
