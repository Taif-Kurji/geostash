import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/settings_model.dart';
import 'l10n/app_localizations.dart';

enum AppLanguage { system, sv, en }

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsModel>();

    final language = switch (settings.locale?.languageCode) {
      'sv' => AppLanguage.sv,
      'en' => AppLanguage.en,
      _ => AppLanguage.system,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.language),
          RadioListTile<AppLanguage>(
            value: AppLanguage.system,
            groupValue: language,
            title: Text(l.systemDefault),
            onChanged: (value) {
              settings.setLocale(null);
            },
          ),
          RadioListTile<AppLanguage>(
            value: AppLanguage.sv,
            groupValue: language,
            title: const Text('Svenska'),
            onChanged: (value) {
              settings.setLocale(const Locale('sv'));
            },
          ),
          RadioListTile<AppLanguage>(
            value: AppLanguage.en,
            groupValue: language,
            title: const Text('English'),
            onChanged: (value) {
              settings.setLocale(const Locale('en'));
            },
          ),
          const SizedBox(height: 16),
          Text(l.appearance),
          RadioListTile<ThemeMode>(
            value: ThemeMode.system,
            groupValue: settings.themeMode,
            title: Text(l.systemDefault),
            onChanged: (value) {
              if (value != null) settings.setThemeMode(value);
            },
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: settings.themeMode,
            title: Text(l.light),
            onChanged: (value) {
              if (value != null) settings.setThemeMode(value);
            },
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: settings.themeMode,
            title: Text(l.dark),
            onChanged: (value) {
              if (value != null) settings.setThemeMode(value);
            },
          ),
        ],
      ),
    );
  }
}
