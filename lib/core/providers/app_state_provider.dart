import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

final selectedLanguageCodeProvider = StateProvider<String>((ref) => 'en');

/// Synchronously loaded theme index — set once in main() before runApp().
int? _initialThemeIndex;

/// Call once in main() so the provider has the correct initial value.
void initThemeMode(int savedIndex) {
  _initialThemeIndex = savedIndex;
}

/// Persisted theme mode preference. Defaults to light (the original theme).
/// Reads the pre-loaded value so there is no flash on startup.
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  if (_initialThemeIndex != null) {
    return ThemeMode.values[_initialThemeIndex!];
  }
  return ThemeMode.light;
});
