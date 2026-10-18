import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ecomins_customer/features/auth/auth_provider.dart';
import 'package:ecomins_customer/features/orders/orders_provider.dart';
import 'package:ecomins_customer/features/orders/orders_screen.dart';
import 'package:ecomins_customer/features/tracking/tracking_provider.dart';

// ── Fakes ────────────────────────────────────────────────────────────────────

class _FakeAuthProvider extends AuthProvider {
  @override
  bool get isLoggedIn => true;
  @override
  bool get isLoading => false;
  @override
  String? get token => 'test-token';
  @override
  String? get phone => '+2348000000000';
  @override
  String get customerId => 'cust-test';
  @override
  bool get hasProfile => true;
}

class _FakeOrdersProvider extends OrdersProvider {
  _FakeOrdersProvider(List<Job> initialJobs) {
    jobs = initialJobs;
    isLoading = false;
  }

  // Override loadJobs to be a no-op so initState doesn't trigger network calls.
  @override
  Future<void> loadJobs(String token, String customerId) async {}
}

// ── Helper ────────────────────────────────────────────────────────────────────

Widget _buildScreen(OrdersProvider ordersProvider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>(create: (_) => _FakeAuthProvider()),
      ChangeNotifierProvider<OrdersProvider>.value(value: ordersProvider),
    ],
    child: const MaterialApp(home: Scaffold(body: OrdersScreen())),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('OrdersScreen', () {
    testWidgets('shows empty state when jobs list is empty', (tester) async {
      final provider = _FakeOrdersProvider([]);

      await tester.pumpWidget(_buildScreen(provider));
      await tester.pumpAndSettle();

      expect(find.text('No orders yet'), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('renders a card for each job in the list', (tester) async {
      final jobs = [
        Job(
          id: 'job-1',
          serviceType: 'Deep Cleaning',
          address: '12 Lagos Street',
          status: JobStatus.pending,
        ),
        Job(
          id: 'job-2',
          serviceType: 'Waste Removal',
          address: '5 Abuja Road',
          status: JobStatus.completed,
        ),
      ];
      final provider = _FakeOrdersProvider(jobs);

      await tester.pumpWidget(_buildScreen(provider));
      await tester.pumpAndSettle();

      expect(find.text('Deep Cleaning'), findsOneWidget);
      expect(find.text('Waste Removal'), findsOneWidget);
    });
  });
}
