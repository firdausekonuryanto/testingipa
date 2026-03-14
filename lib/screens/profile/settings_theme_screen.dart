import 'package:flutter/material.dart';
import 'package:internusa_group/utils/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsThemeScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  const SettingsThemeScreen({super.key, required this.onThemeChanged});

  @override
  State<SettingsThemeScreen> createState() => _SettingsThemeScreenState();
}

class _SettingsThemeScreenState extends State<SettingsThemeScreen> {
  late ThemeMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme_mode') ?? 'system';
    setState(() {
      _selectedMode = _stringToThemeMode(theme);
    });
  }

  Future<void> _saveThemePreference(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _themeModeToString(mode));
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  ThemeMode _stringToThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void _onModeSelected(ThemeMode mode) {
    setState(() {
      _selectedMode = mode;
    });
    _saveThemePreference(mode);
    widget.onThemeChanged(mode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Pengaturan Tema',
        style: TextStyle(
            fontSize: AppDimens.fontTitle, fontWeight: FontWeight.w600),
      )),
      body: Column(
        children: [
          RadioListTile<ThemeMode>(
            title: Text(
              'Terang',
              style: TextStyle(
                  fontSize: AppDimens.fontBody, fontWeight: FontWeight.normal),
            ),
            value: ThemeMode.light,
            groupValue: _selectedMode,
            onChanged: (value) {
              if (value != null) _onModeSelected(value);
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(
              'Gelap',
              style: TextStyle(
                  fontSize: AppDimens.fontBody, fontWeight: FontWeight.normal),
            ),
            value: ThemeMode.dark,
            groupValue: _selectedMode,
            onChanged: (value) {
              if (value != null) _onModeSelected(value);
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(
              'Ikuti Sistem',
              style: TextStyle(
                  fontSize: AppDimens.fontBody, fontWeight: FontWeight.normal),
            ),
            value: ThemeMode.system,
            groupValue: _selectedMode,
            onChanged: (value) {
              if (value != null) _onModeSelected(value);
            },
          ),
        ],
      ),
    );
  }
}
