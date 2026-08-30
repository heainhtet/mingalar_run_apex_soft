import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../features/profile/data/models/user_profile_hive_model.dart';
import '../../features/run/data/models/run_activity_hive_model.dart';

abstract final class HiveBoxNames {
  static const String profile = 'profile';
  static const String runActivities = 'run_activities';
}

abstract final class HiveKeys {
  static const String currentUser = 'current_user';
}

abstract final class HiveDatabase {
  /// Registers the app-owned schema and opens every box before providers read
  /// from them. Keeping startup here prevents persistence details leaking into UI.
  static Future<void> initialize() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(UserProfileHiveAdapter.typeIdValue)) {
      Hive.registerAdapter(UserProfileHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(RunActivityHiveAdapter.typeIdValue)) {
      Hive.registerAdapter(RunActivityHiveAdapter());
    }

    await Future.wait([
      Hive.openBox<UserProfileHiveModel>(HiveBoxNames.profile),
      Hive.openBox<RunActivityHiveModel>(HiveBoxNames.runActivities),
    ]);
  }
}
