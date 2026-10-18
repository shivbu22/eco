import 'package:flutter/material.dart';

class MockupTheme {
  static const Color background = Color(0xFFF8F9FA); // Off-white
  static const Color surface = Colors.white;
  static const Color primary = Color(0xFFFF2972); // Snappy pink
  static const Color onPrimary = Colors.white;
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textGrey = Color(0xFF757575);
  static const Color cardShadow = Color(0x0C000000);
  static const Color divider = Color(0xFFEEEEEE);
  
  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(color: cardShadow, blurRadius: 10, offset: Offset(0, 4)),
      ],
      border: Border.all(color: divider),
    );
  }
}
