import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode;

  ThemeProvider(this._isDarkMode) {
    loadThemeFromPrefs();
  }

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme =>
      _isDarkMode
          ? ThemeData.dark().copyWith(
            primaryColor: Colors.teal,
            colorScheme: const ColorScheme.dark(
              primary: Colors.teal,
              secondary: Colors.tealAccent,
            ),
          )
          : ThemeData.light().copyWith(
            primaryColor: Colors.teal,
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
              secondary: Colors.tealAccent,
            ),
          );

  Future<void> loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? _isDarkMode;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> resetToDefault() async {
    _isDarkMode = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', false);
    notifyListeners();
  }
}
