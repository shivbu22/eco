import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class WorkersScreen extends StatefulWidget {
  const WorkersScreen({super.key});

  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends State<WorkersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AdminProvider>().loadWorkers());
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
              Text('Workers',
                  style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              FilledButton.icon(
                onPressed: provider.loadWorkers,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (provider.loadingWorkers)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Phone')),
                    DataColumn(label: Text('Zone')),
                    DataColumn(label: Text('KYC')),
                    DataColumn(label: Text('Available')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: provider.workers.map((w) {
                    final worker = w as Map<String, dynamic>;
                    final kyc = worker['kyc_status'] as String? ?? 'pending';
                    return DataRow(cells: [
                      DataCell(Text(worker['name'] as String? ?? '')),
                      DataCell(Text(worker['phone'] as String? ?? '')),
                      DataCell(Text(worker['zone_id'] as String? ?? '')),
                      DataCell(Chip(
                        label: Text(kyc,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11)),
                        backgroundColor: kyc == 'verified'
                            ? Colors.green
                            : kyc == 'rejected'
                                ? Colors.red
                                : Colors.orange,
                        padding: EdgeInsets.zero,
                      )),
                      DataCell(Icon(
                        worker['availability'] == true
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: worker['availability'] == true
                            ? Colors.green
                            : Colors.grey,
                      )),
                      DataCell(kyc == 'pending'
                          ? Row(
                              children: [
                                TextButton(
                                  onPressed: () => provider
                                      .approveKyc(worker['id'] as String),
                                  child: const Text('Approve'),
                                ),
                                TextButton(
                                  onPressed: () => provider.rejectKyc(
                                      worker['id'] as String,
                                      'Documents unclear'),
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.red),
                                  child: const Text('Reject'),
                                ),
                              ],
                            )
                          : const SizedBox.shrink()),
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
