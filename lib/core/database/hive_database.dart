import 'dart:io';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../features/profile/data/models/user_profile_hive_model.dart';
import '../../features/run/data/models/run_activity_hive_model.dart';
import '../../features/run/data/models/run_session_hive_model.dart';
import '../utils/logger.dart';

abstract final class HiveBoxNames {
  static const String preferences = 'preferences';
  static const String settings = 'settings';
  static const String profile = 'profile';
  static const String runActivities = 'run_activities';
  static const String runSession = 'run_session';
}

abstract final class HiveKeys {
  static const String onboardingCompleted = 'onboarding_completed';
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String currentUser = 'current_user';
  static const String activeRun = 'active_run';
}

abstract final class HiveDatabase {
  static Future<void> initialize() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(UserProfileHiveAdapter.typeIdValue)) {
      Hive.registerAdapter(UserProfileHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(RunActivityHiveAdapter.typeIdValue)) {
      Hive.registerAdapter(RunActivityHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(RunSessionHiveAdapter.typeIdValue)) {
      Hive.registerAdapter(RunSessionHiveAdapter());
    }

    await Future.wait([
      Hive.openBox<bool>(HiveBoxNames.preferences),
      Hive.openBox<String>(HiveBoxNames.settings),
      Hive.openBox<UserProfileHiveModel>(HiveBoxNames.profile),
      Hive.openBox<RunActivityHiveModel>(HiveBoxNames.runActivities),
      Hive.openBox<RunSessionHiveModel>(HiveBoxNames.runSession),
    ]);
    logger.i('Hive database initialized');
  }

  static Future<void> clearAllUserData() async {
    final avatarPath = Hive.box<UserProfileHiveModel>(
      HiveBoxNames.profile,
    ).get(HiveKeys.currentUser)?.avatarPath;
    await Future.wait([
      Hive.box<bool>(HiveBoxNames.preferences).clear(),
      Hive.box<String>(HiveBoxNames.settings).clear(),
      Hive.box<UserProfileHiveModel>(HiveBoxNames.profile).clear(),
      Hive.box<RunActivityHiveModel>(HiveBoxNames.runActivities).clear(),
      Hive.box<RunSessionHiveModel>(HiveBoxNames.runSession).clear(),
    ]);
    if (avatarPath != null) {
      final avatar = File(avatarPath);
      if (await avatar.exists()) await avatar.delete();
    }
    logger.i('All local user data cleared');
  }
}
