import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import '../database/hive_database.dart';

enum AppLanguage {
  english(Locale('en', 'US')),
  burmese(Locale('my', 'MM'));

  const AppLanguage(this.locale);

  final Locale locale;

  static AppLanguage fromCode(String? value) => switch (value) {
    'my_MM' => AppLanguage.burmese,
    _ => AppLanguage.english,
  };
}

class AppSettings {
  const AppSettings({required this.themeMode, required this.language});

  final ThemeMode themeMode;
  final AppLanguage language;

  AppSettings copyWith({ThemeMode? themeMode, AppLanguage? language}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
    );
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );

class AppSettingsController extends Notifier<AppSettings> {
  Box<String> get _box => Hive.box<String>(HiveBoxNames.settings);

  @override
  AppSettings build() {
    final mode = _box.get(HiveKeys.themeMode);
    return AppSettings(
      themeMode: mode == 'dark' ? ThemeMode.dark : ThemeMode.light,
      language: AppLanguage.fromCode(_box.get(HiveKeys.language)),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _box.put(HiveKeys.themeMode, mode.name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setLanguage(AppLanguage language) async {
    await _box.put(HiveKeys.language, language.locale.toString());
    state = state.copyWith(language: language);
  }
}
