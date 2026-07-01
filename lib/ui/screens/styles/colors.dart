import 'package:flutter/material.dart';

class AppColors {
  /// KEEP STATIC COLORS
  static const Color primary = Color(0xFF3D6766);
  static const Color accent = Color(0xFFB3D1D1);
  static const Color border = Color(0xFF3D6766);
  static const Color psycardborder = Color(0xFF6EB5B5);
  /// 🔥 RESTORE THESE (VERY IMPORTANT)
  static const Color textDark = Colors.black87;
  static const Color textLight = Colors.white;

  /// OLD (DON’T USE NOW)
  static const Color cardBackground = Colors.white;
  static const Color hisbgd = Color(0xFFF4FAF9);

  /// 🔥 NEW DYNAMIC COLORS

  static Color background(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  static Color card(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  static Color text(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.color!;
  }

  static Color input(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  /// SAME
  static const Color success = Color(0xFF00A86B);
  static const Color error = Color(0xFFC62828);
}