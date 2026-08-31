import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import 'hive_database.dart';

abstract interface class AppPreferences {
  bool get hasCompletedOnboarding;

  Future<void> completeOnboarding();
}

class HiveAppPreferences implements AppPreferences {
  HiveAppPreferences(this._box);

  factory HiveAppPreferences.openedBox() =>
      HiveAppPreferences(Hive.box<bool>(HiveBoxNames.preferences));

  final Box<bool> _box;

  @override
  bool get hasCompletedOnboarding =>
      _box.get(HiveKeys.onboardingCompleted, defaultValue: false) ?? false;

  @override
  Future<void> completeOnboarding() =>
      _box.put(HiveKeys.onboardingCompleted, true);
}

final appPreferencesProvider = Provider<AppPreferences>((ref) {
  return HiveAppPreferences.openedBox();
});
