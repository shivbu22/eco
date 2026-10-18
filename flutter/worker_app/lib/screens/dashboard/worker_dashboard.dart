import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';
import '../jobs/job_feed_screen.dart';
import '../earnings/earnings_screen.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  int _tab = 0;

  final _screens = const [JobFeedScreen(), EarningsScreen()];

  @override
  Widget build(BuildContext context) {
    final worker = context.watch<WorkerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ecomins Worker'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          // Availability toggle
          Row(
            children: [
              Text(worker.available ? 'Online' : 'Offline',
                  style: const TextStyle(color: Colors.white)),
              Switch(
                value: worker.available,
                onChanged: (_) => worker.toggleAvailability(),
                activeThumbColor: Colors.greenAccent,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => worker.logout(),
          ),
        ],
      ),
      body: _screens[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.work), label: 'Jobs'),
          NavigationDestination(
              icon: Icon(Icons.account_balance_wallet), label: 'Earnings'),
        ],
      ),
    );
  }
}
