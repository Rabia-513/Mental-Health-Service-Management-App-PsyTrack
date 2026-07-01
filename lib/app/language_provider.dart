import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {

  bool isUrdu = false;

  void toggleLanguage(bool value) {
    isUrdu = value;
    notifyListeners();
  }
  void setLanguage(bool value) {
    isUrdu = value;
    notifyListeners();
  }

}
