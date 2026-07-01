import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool notifications = true;
  bool aiSuggestions = true;
  bool darkMode = false;

  void toggleNotifications(bool val) {
    notifications = val;
    notifyListeners();
  }

  void toggleAI(bool val) {
    aiSuggestions = val;
    notifyListeners();
  }

  void toggleDarkMode(bool val) {
    darkMode = val;
    notifyListeners();
  }
  bool twoFactor = false;

  void toggleTwoFactor(bool val) {
    twoFactor = val;
    notifyListeners();
  }
  Color primaryColor = const Color(0xff4E7D7A);

  void changeThemeColor(Color color) {
    primaryColor = color;
    notifyListeners();
  }
  double fontScale = 1.0;

  void changeFontSize(double scale) {
    fontScale = scale;
    notifyListeners();
  }

}