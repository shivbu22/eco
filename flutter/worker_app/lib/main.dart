import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/worker_provider.dart';
import 'screens/auth/worker_phone_screen.dart';
import 'screens/dashboard/worker_dashboard.dart';

void main() => runApp(const EcominsWorkerApp());

class EcominsWorkerApp extends StatelessWidget {
  const EcominsWorkerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => WorkerProvider())],
      child: MaterialApp(
        title: 'Ecomins Worker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
          useMaterial3: true,
        ),
        home: const WorkerAppRoot(),
      ),
    );
  }
}

class WorkerAppRoot extends StatelessWidget {
  const WorkerAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final w = context.watch<WorkerProvider>();
    return w.isLoggedIn ? const WorkerDashboard() : const WorkerPhoneScreen();
  }
}
