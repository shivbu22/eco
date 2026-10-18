import 'package:flutter/material.dart';
import 'jobs_screen.dart';
import 'workers_screen.dart';
import 'analytics_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _rail = 0;

  final _screens = const [JobsScreen(), WorkersScreen(), AnalyticsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _rail,
            onDestinationSelected: (i) => setState(() => _rail = i),
            labelType: NavigationRailLabelType.all,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Icon(Icons.eco, size: 32, color: Color(0xFF2E7D32)),
                  SizedBox(height: 4),
                  Text('Admin',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                  icon: Icon(Icons.list_alt), label: Text('Jobs')),
              NavigationRailDestination(
                  icon: Icon(Icons.people), label: Text('Workers')),
              NavigationRailDestination(
                  icon: Icon(Icons.bar_chart), label: Text('Analytics')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _screens[_rail]),
        ],
      ),
    );
  }
}
