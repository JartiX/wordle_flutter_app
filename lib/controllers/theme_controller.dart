import 'package:flutter/material.dart';

import '../controllers/settings_controller.dart';

class ThemeController {
  final SettingsController _settings;

  late ValueNotifier<String> _theme;

  ThemeMode get themeMode {
    switch (_theme.value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  ThemeController(this._settings) {
    _theme = ValueNotifier<String>(_settings.theme.value);

    _settings.theme.addListener(() {
      _theme.value = _settings.theme.value;
    });
  }

  void toggleTheme(BuildContext context) {
    final currentTheme = _theme.value;

    ThemeMode newMode;

    if (currentTheme == 'system') {
      final brightness = MediaQuery.of(context).platformBrightness;
      newMode = brightness == Brightness.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    } else if (currentTheme == 'dark') {
      newMode = ThemeMode.light;
    } else {
      newMode = ThemeMode.dark;
    }

    _settings.setTheme(newMode.name);
  }

  void setTheme(ThemeMode mode) {
    _settings.setTheme(mode.name);
  }

  void dispose() {
    _theme.dispose();
  }
}
