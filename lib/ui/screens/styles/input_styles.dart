import 'package:flutter/material.dart';
import 'colors.dart';

class AppInputStyles {
  static InputDecoration inputDecoration(
      BuildContext context,
      String label, {
        Widget? prefixIcon,
      }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: prefixIcon,
      filled: true,

      /// ✅ FIXED
      fillColor: Theme.of(context).cardColor,

      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border, width: 1.4),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border, width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error, width: 1.6),
      ),
    );
  }
}