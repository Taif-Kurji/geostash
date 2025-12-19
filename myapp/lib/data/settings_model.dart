import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel() {
    _load();
  }

  static const _themeKey = 'themeMode';
  static const _localeKey = 'locale';

  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;
  bool get isLoading => !_loaded;

  Future<void> _load() async {
    // Läs sparade inställningar från SharedPreferences.
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeKey);
    _themeMode = switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final localeValue = prefs.getString(_localeKey);
    _locale = switch (localeValue) {
      'sv' => const Locale('sv'),
      'en' => const Locale('en'),
      _ => null,
    };
    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    // Uppdatera tema och spara lokalt.
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _themeKey,
      switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      },
    );
  }

  Future<void> setLocale(Locale? locale) async {
    //  Uppdatera språk och spara/ta bort från prefs.
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_localeKey);
      return;
    }
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> toggleTheme() async {
    final next = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }
}
