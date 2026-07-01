import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  // "Light" / "Dark"
  void setThemeString(String value) {
    final newMode = (value == "Dark") ? ThemeMode.dark : ThemeMode.light;
    if (_themeMode == newMode) return;
    _themeMode = newMode;
    notifyListeners();
  }

  String get themeString => _themeMode == ThemeMode.dark ? "Dark" : "Light";
}