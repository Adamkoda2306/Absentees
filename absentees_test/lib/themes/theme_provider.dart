import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Default to system theme
  ThemeMode _themeMode = ThemeMode.system;

  // Get theme mode
  ThemeMode get themeMode => _themeMode;

  // Set theme mode
  set themeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }

  // Toggle theme
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }
}
