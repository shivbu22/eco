import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/phone_screen.dart';
import 'features/booking/booking_provider.dart';
import 'features/home/home_screen.dart';
import 'features/orders/orders_provider.dart';
import 'features/rewards/rewards_provider.dart';
import 'features/tracking/tracking_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // kDevMode is defined in auth_provider.dart — skip Firebase init in dev mode
  if (!kDevMode) await Firebase.initializeApp();
  runApp(const EcominsApp());
}

class EcominsApp extends StatelessWidget {
  const EcominsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => TrackingProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => RewardsProvider()),
      ],
      child: MaterialApp(
        title: 'Ecomins',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return auth.isLoggedIn ? const HomeScreen() : const PhoneScreen();
  }
}
