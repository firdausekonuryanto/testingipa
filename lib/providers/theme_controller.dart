import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeOption { light, dark, system }

class ThemeController extends ChangeNotifier with WidgetsBindingObserver {
  ThemeModeOption _themeMode = ThemeModeOption.system;
  ThemeMode _currentMode = ThemeMode.system;

  ThemeMode get themeMode => _currentMode;
  ThemeModeOption get themeModeOption => _themeMode;

  ThemeController() {
    WidgetsBinding.instance.addObserver(this);
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('theme_mode') ?? 'system';

    switch (saved) {
      case 'light':
        _themeMode = ThemeModeOption.light;
        _currentMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeModeOption.dark;
        _currentMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeModeOption.system;
        _updateSystemBrightness();
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeModeOption mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);

    _themeMode = mode;
    if (mode == ThemeModeOption.system) {
      _updateSystemBrightness();
    } else {
      _currentMode =
          (mode == ThemeModeOption.dark) ? ThemeMode.dark : ThemeMode.light;
    }
    notifyListeners();
  }

  void _updateSystemBrightness() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _currentMode =
        (brightness == Brightness.dark) ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  void didChangePlatformBrightness() {
    if (_themeMode == ThemeModeOption.system) {
      _updateSystemBrightness();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
