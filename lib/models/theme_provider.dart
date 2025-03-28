import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  static const String _darkModeKey = 'isDarkMode';
  late Future<void> initialized;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    initialized = _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if a preference has been set
      if (prefs.containsKey(_darkModeKey)) {
        _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
      } else {
        // If no preference is set, use system theme
        var brightness =
            SchedulerBinding.instance.platformDispatcher.platformBrightness;
        _isDarkMode = brightness == Brightness.dark;

        // Save this initial preference
        await prefs.setBool(_darkModeKey, _isDarkMode);
      }

      notifyListeners();
    } catch (e) {
      // If there's an error loading preferences, check system theme
      var brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      _isDarkMode = brightness == Brightness.dark;
      debugPrint('Error loading theme preference: $e');
    }
  }

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme() async {
    await setDarkMode(!_isDarkMode);
  }

  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode == isDark) return;

    _isDarkMode = isDark;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, isDark);
    } catch (e) {
      // Handle error saving preferences
      debugPrint('Error saving theme preference: $e');
    }
  }
}
