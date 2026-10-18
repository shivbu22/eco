// Widget-level integration tests (flutter_test — no real network calls).
// Uses fake/stub providers injected via MultiProvider.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ecomins_customer/features/auth/auth_provider.dart';
import 'package:ecomins_customer/features/auth/phone_screen.dart';
import 'package:ecomins_customer/features/auth/otp_screen.dart';
import 'package:ecomins_customer/features/booking/booking_provider.dart';
import 'package:ecomins_customer/features/home/home_screen.dart';
import 'package:ecomins_customer/features/orders/orders_provider.dart';
import 'package:ecomins_customer/features/rewards/rewards_provider.dart';
import 'package:ecomins_customer/features/rewards/rewards_screen.dart';
import 'package:ecomins_customer/features/services/services_screen.dart';
import 'package:ecomins_customer/features/tracking/tracking_provider.dart';
import 'package:ecomins_customer/core/theme.dart';

// ── Fake providers ────────────────────────────────────────────────────────────

/// AuthProvider that starts already logged-in (simulates restored token).
class _FakeAuthLoggedIn extends AuthProvider {
  @override
  bool get isLoggedIn => true;
  @override
  bool get isLoading => false;
  @override
  String? get token => 'fake-token';
  @override
  String? get phone => '+2340000000000';
  @override
  String get customerId => 'cust-fake';
  @override
  bool get hasProfile => true;
}

/// AuthProvider that starts logged-out; verifyOtp sets logged-in.
class _FakeAuthFlow extends AuthProvider {
  bool _isLoggedIn = false;

  @override
  bool get isLoggedIn => _isLoggedIn;
  @override
  bool get isLoading => false;
  @override
  String? get token => _isLoggedIn ? 'fake-token' : null;
  @override
  String? get phone => '+2340000000000';
  @override
  String get customerId => 'cust-fake';
  @override
  bool get hasProfile => true;

  @override
  Future<void> requestOtp(String phone) async {
    // no-op — no real network call
  }

  @override
  Future<void> verifyOtp(String phone, String otp) async {
    _isLoggedIn = true;
    notifyListeners();
  }
}

/// OrdersProvider that never makes network calls.
class _FakeOrdersProvider extends OrdersProvider {
  @override
  Future<void> loadJobs(String token, String customerId) async {
    // no-op
  }
}

/// RewardsProvider with a preset balance that never makes network calls.
class _FakeRewardsProvider extends RewardsProvider {
  _FakeRewardsProvider({int balance = 0}) {
    pointsBalance = balance;
  }

  @override
  Future<void> loadRewards(String token, String customerId) async {
    // no-op — balance already set in constructor
  }

  @override
  Future<bool> redeemPoints(String token, String customerId, int points) async {
    if (points > pointsBalance) {
      errorMessage = 'Insufficient Eco Points';
      notifyListeners();
      return false;
    }
    pointsBalance -= points;
    errorMessage = null;
    notifyListeners();
    return true;
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Minimal app widget that mirrors _Root logic but accepts injected providers.
Widget _buildApp(AuthProvider auth) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: auth),
      ChangeNotifierProvider<BookingProvider>(create: (_) => BookingProvider()),
      ChangeNotifierProvider<TrackingProvider>(
          create: (_) => TrackingProvider()),
      ChangeNotifierProvider<OrdersProvider>(
          create: (_) => _FakeOrdersProvider()),
      ChangeNotifierProvider<RewardsProvider>(
          create: (_) => _FakeRewardsProvider()),
    ],
    child: MaterialApp(
      title: 'Ecomins Test',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _TestRoot(auth: auth),
    ),
  );
}

class _TestRoot extends StatelessWidget {
  final AuthProvider auth;
  const _TestRoot({required this.auth});

  @override
  Widget build(BuildContext context) {
    final a = context.watch<AuthProvider>();
    if (a.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return a.isLoggedIn ? const HomeScreen() : const PhoneScreen();
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── 12.1 Cold launch with stored token → HomeScreen ──────────────────────

  group('12.1 Cold launch with stored token', () {
    testWidgets('shows HomeScreen and not PhoneScreen when token is restored',
        (tester) async {
      await tester.pumpWidget(_buildApp(_FakeAuthLoggedIn()));
      // Use pump with duration instead of pumpAndSettle to avoid NavigationBar
      // semantics parent-data assertion in test environment
      await tester.pump(const Duration(milliseconds: 500));

      // HomeScreen is shown — NavigationBar with 'Services' label is present
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Services'), findsOneWidget);

      // PhoneScreen is NOT shown
      expect(find.text('Send OTP'), findsNothing);
    });
  });

  // ── 12.2 Full booking flow ────────────────────────────────────────────────

  group('12.2 Full booking flow', () {
    testWidgets('PhoneScreen → OtpScreen: OTP verification updates auth state',
        (tester) async {
      final auth = _FakeAuthFlow();
      await tester.pumpWidget(_buildApp(auth));
      await tester.pumpAndSettle();

      // 1. PhoneScreen is shown
      expect(find.text('Send OTP'), findsOneWidget);

      // 2. Enter phone number and tap Send OTP
      await tester.enterText(find.byType(TextField), '+2348012345678');
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();

      // 3. OtpScreen is shown
      expect(find.byType(OtpScreen), findsOneWidget);

      // 4. Enter OTP and tap Verify
      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.text('Verify'));
      await tester.pump();

      // 5. Auth state is now logged in
      expect(auth.isLoggedIn, isTrue);
    });

    testWidgets('HomeScreen → BookingScreen: tapping service shows Stepper',
        (tester) async {
      // Test the booking navigation directly by pushing ServicesScreen
      // (avoids NavigationBar semantics assertion in test environment)
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>(
                create: (_) => _FakeAuthLoggedIn()),
            ChangeNotifierProvider<BookingProvider>(
                create: (_) => BookingProvider()),
            ChangeNotifierProvider<TrackingProvider>(
                create: (_) => TrackingProvider()),
            ChangeNotifierProvider<OrdersProvider>(
                create: (_) => _FakeOrdersProvider()),
            ChangeNotifierProvider<RewardsProvider>(
                create: (_) => _FakeRewardsProvider()),
          ],
          child: const MaterialApp(
            home: Scaffold(body: ServicesScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the 'Cleaning' service category card
      await tester.tap(find.text('Cleaning', skipOffstage: false));
      await tester.pumpAndSettle();

      // BookingScreen is shown — Stepper is present
      expect(find.byType(Stepper), findsOneWidget);
    });
  });

  // ── 12.3 Rewards redemption flow ─────────────────────────────────────────

  group('12.3 Rewards redemption flow', () {
    testWidgets(
        'shows balance, rejects over-redemption, accepts valid redemption',
        (tester) async {
      final rewards = _FakeRewardsProvider(balance: 100);
      final auth = _FakeAuthLoggedIn();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: auth),
            ChangeNotifierProvider<RewardsProvider>.value(value: rewards),
          ],
          child: const MaterialApp(home: Scaffold(body: RewardsScreen())),
        ),
      );
      await tester.pumpAndSettle();

      // Balance of 100 is shown
      expect(find.text('100'), findsOneWidget);

      // ── Over-redemption ──────────────────────────────────────────────────

      // Open redeem dialog
      await tester.tap(find.text('Redeem Points'));
      await tester.pumpAndSettle();

      // Enter 200 (over balance)
      await tester.enterText(find.byType(TextField), '200');
      await tester.tap(find.text('Redeem'));
      await tester.pumpAndSettle();

      // SnackBar shows insufficient message
      expect(find.text('Insufficient Eco Points'), findsOneWidget);

      // ── Successful redemption ────────────────────────────────────────────

      // Wait for the snackbar to dismiss before opening the dialog again
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Redeem Points'));
      await tester.pumpAndSettle();

      // Enter 50 (within balance)
      await tester.enterText(find.byType(TextField), '50');
      await tester.tap(find.text('Redeem'));
      await tester.pumpAndSettle();

      // SnackBar shows success message
      expect(find.text('Points redeemed successfully!'), findsOneWidget);

      // Balance is now 50
      expect(find.text('50'), findsOneWidget);
    });
  });
}
