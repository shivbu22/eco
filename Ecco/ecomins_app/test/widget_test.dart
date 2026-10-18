import 'package:flutter_test/flutter_test.dart';

import 'package:ecomins_app/main.dart';

void main() {
  testWidgets('App starts smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OzoMinApp());
    await tester.pump(const Duration(seconds: 1));
    // Verify splash screen renders
    expect(find.text('Ozomin'), findsOneWidget);
  });
}
