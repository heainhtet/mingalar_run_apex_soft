import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferencesService {
  static const _key = 'theme_mode';

  static Future<int?> getSavedThemeIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_key);
    return value;
  }

  static Future<void> saveThemeIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, index);
  }
}
