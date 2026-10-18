import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomins_customer/features/services/services_screen.dart';

void main() {
  group('ServicesScreen', () {
    testWidgets('renders all 5 category labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ServicesScreen())),
      );
      await tester.pumpAndSettle();

      // Use skipOffstage: false so items scrolled out of view are still found
      expect(find.text('Cleaning', skipOffstage: false), findsOneWidget);
      expect(find.text('Waste Management', skipOffstage: false), findsOneWidget);
      expect(find.text('Logistics', skipOffstage: false), findsOneWidget);
      expect(find.text('B2B Services', skipOffstage: false), findsOneWidget);
      expect(find.text('Recycling', skipOffstage: false), findsOneWidget);
    });

    testWidgets('shows sub-service count for Cleaning card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ServicesScreen())),
      );
      await tester.pumpAndSettle();

      // Cleaning has 4 sub-services
      expect(find.text('4 services', skipOffstage: false), findsWidgets);
    });
  });
}
