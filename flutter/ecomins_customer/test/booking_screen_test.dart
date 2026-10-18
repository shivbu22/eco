import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ecomins_customer/features/auth/auth_provider.dart';
import 'package:ecomins_customer/features/booking/booking_provider.dart';
import 'package:ecomins_customer/features/booking/booking_screen.dart';

/// Minimal stub that avoids SharedPreferences and network calls in tests.
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

Widget _buildScreen({
  BookingProvider? bookingProvider,
  int initialStep = 0,
  String categoryId = 'cleaning',
  String categoryLabel = 'Cleaning',
  List<String> subServices = const ['Deep Clean', 'Regular Clean'],
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => _FakeAuthProvider(),
      ),
      ChangeNotifierProvider<BookingProvider>(
        create: (_) => bookingProvider ?? BookingProvider(),
      ),
    ],
    child: MaterialApp(
      home: BookingScreen(
        categoryId: categoryId,
        categoryLabel: categoryLabel,
        subServices: subServices,
        initialStep: initialStep,
      ),
    ),
  );
}

void main() {
  group('BookingScreen step validation', () {
    testWidgets(
        'step 0: tapping Continue without selecting a service shows snackbar',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Invoke the Stepper's onStepContinue callback directly.
      // This bypasses the IgnorePointer that Flutter's Stepper wraps around
      // controlsBuilder output during AnimatedCrossFade transitions.
      final stepper = tester.widget<Stepper>(find.byType(Stepper));
      stepper.onStepContinue!();
      await tester.pumpAndSettle();

      expect(find.text('Select a service'), findsOneWidget);
    });

    testWidgets(
        'step 1: tapping Continue without entering address shows snackbar',
        (tester) async {
      // Start directly at step 1 with a pre-fetched price to bypass step 0
      final booking = BookingProvider()
        ..selectedSubService = 'Deep Clean'
        ..estimatedPrice = 500.0;

      await tester.pumpWidget(
        _buildScreen(bookingProvider: booking, initialStep: 1),
      );
      await tester.pumpAndSettle();

      // Invoke the Stepper's onStepContinue callback directly.
      // This bypasses the IgnorePointer that Flutter's Stepper wraps around
      // controlsBuilder output during AnimatedCrossFade transitions.
      final stepper = tester.widget<Stepper>(find.byType(Stepper));
      stepper.onStepContinue!();
      await tester.pumpAndSettle();

      expect(find.text('Enter your address'), findsOneWidget);
    });
  });
}
