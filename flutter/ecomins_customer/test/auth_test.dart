import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ecomins_customer/features/auth/auth_provider.dart';
import 'package:ecomins_customer/features/auth/phone_screen.dart';
import 'package:ecomins_customer/features/auth/otp_screen.dart';

// ---------------------------------------------------------------------------
// Mock AuthProvider
// ---------------------------------------------------------------------------

class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  bool requestOtpCalled = false;
  bool verifyOtpCalled = false;
  bool shouldThrowOnVerify = false;
  bool shouldThrowOnRequest = false;

  @override
  bool get isLoggedIn => false;

  @override
  bool get isLoading => false;

  @override
  String? get token => null;

  @override
  String? get phone => null;

  @override
  String get customerId => 'mock-cust';

  @override
  String? customerName;

  @override
  String? customerAddress;

  @override
  bool get hasProfile => false;

  @override
  Future<void> requestOtp(String phone) async {
    requestOtpCalled = true;
    if (shouldThrowOnRequest) throw Exception('Request failed');
  }

  @override
  Future<void> verifyOtp(String phone, String otp) async {
    verifyOtpCalled = true;
    if (shouldThrowOnVerify) throw Exception('Invalid OTP');
  }

  @override
  Future<void> saveProfile(String name, String address) async {}

  @override
  Future<void> logout() async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrapWithProvider(Widget child, MockAuthProvider provider) {
  return ChangeNotifierProvider<AuthProvider>.value(
    value: provider,
    child: MaterialApp(home: child),
  );
}

// ---------------------------------------------------------------------------
// PhoneScreen tests
// ---------------------------------------------------------------------------

void main() {
  group('PhoneScreen', () {
    testWidgets('renders phone input field and Send OTP button',
        (tester) async {
      final mock = MockAuthProvider();
      await tester.pumpWidget(_wrapWithProvider(const PhoneScreen(), mock));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);
    });

    testWidgets('tapping Send OTP with empty field does not call requestOtp',
        (tester) async {
      final mock = MockAuthProvider();
      await tester.pumpWidget(_wrapWithProvider(const PhoneScreen(), mock));

      await tester.tap(find.text('Send OTP'));
      await tester.pump();

      expect(mock.requestOtpCalled, isFalse);
    });

    testWidgets('entering valid phone and tapping Send OTP calls requestOtp',
        (tester) async {
      final mock = MockAuthProvider();
      await tester.pumpWidget(_wrapWithProvider(const PhoneScreen(), mock));

      await tester.enterText(find.byType(TextField), '+2348012345678');
      await tester.tap(find.text('Send OTP'));
      await tester.pump();

      expect(mock.requestOtpCalled, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // OtpScreen tests
  // -------------------------------------------------------------------------

  group('OtpScreen', () {
    testWidgets('renders OTP input field and Verify button', (tester) async {
      final mock = MockAuthProvider();
      await tester.pumpWidget(
          _wrapWithProvider(const OtpScreen(phone: '+2348012345678'), mock));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Verify'), findsOneWidget);
    });

    testWidgets('tapping Verify with less than 6 digits shows snackbar',
        (tester) async {
      final mock = MockAuthProvider();
      await tester.pumpWidget(
          _wrapWithProvider(const OtpScreen(phone: '+2348012345678'), mock));

      await tester.enterText(find.byType(TextField), '123');
      await tester.tap(find.text('Verify'));
      await tester.pump();

      expect(find.text('Enter 6-digit OTP'), findsOneWidget);
      expect(mock.verifyOtpCalled, isFalse);
    });

    testWidgets('shows error SnackBar when OTP verification fails',
        (tester) async {
      final mock = MockAuthProvider()..shouldThrowOnVerify = true;
      await tester.pumpWidget(
          _wrapWithProvider(const OtpScreen(phone: '+2348012345678'), mock));

      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.text('Verify'));
      await tester.pump();

      expect(find.text('Exception: Invalid OTP'), findsOneWidget);
    });
  });
}
