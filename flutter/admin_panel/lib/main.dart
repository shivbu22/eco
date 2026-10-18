import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/admin_provider.dart';
import 'screens/dashboard_screen.dart';

void main() => runApp(const EcominsAdminApp());

class EcominsAdminApp extends StatelessWidget {
  const EcominsAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AdminProvider())],
      child: MaterialApp(
        title: 'Ecomins Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF37474F)),
          useMaterial3: true,
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
