import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AdminProvider>().loadJobs());
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'completed': return Colors.green;
      case 'in_progress': return Colors.blue;
      case 'cancelled': return Colors.red;
      case 'assigned': return Colors.purple;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Jobs', style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              DropdownButton<String?>(
                value: _filterStatus,
                hint: const Text('Filter by status'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ...['pending', 'assigned', 'in_progress', 'completed', 'cancelled']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s))),
                ],
                onChanged: (v) {
                  setState(() => _filterStatus = v);
                  provider.loadJobs(status: v);
                },
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => provider.loadJobs(status: _filterStatus),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (provider.loadingJobs)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Service')),
                    DataColumn(label: Text('Address')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Price')),
                  ],
                  rows: provider.jobs.map((j) {
                    final job = j as Map<String, dynamic>;
                    final status = job['status'] as String? ?? '';
                    return DataRow(cells: [
                      DataCell(Text((job['id'] as String).substring(0, 8))),
                      DataCell(Text(job['service_type'] as String? ?? '')),
                      DataCell(Text(
                          job['location']?['address'] as String? ?? '')),
                      DataCell(Chip(
                        label: Text(status,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11)),
                        backgroundColor: _statusColor(status),
                        padding: EdgeInsets.zero,
                      )),
                      DataCell(Text('₦${job['price'] ?? 0}')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
