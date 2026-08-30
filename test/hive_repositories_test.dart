import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mingalar_un/core/database/hive_database.dart';
import 'package:mingalar_un/features/profile/data/models/user_profile_hive_model.dart';
import 'package:mingalar_un/features/profile/data/repositories/hive_profile_repository.dart';
import 'package:mingalar_un/features/profile/domain/entities/user_profile.dart';
import 'package:mingalar_un/features/run/data/models/run_activity_hive_model.dart';
import 'package:mingalar_un/features/run/data/repositories/hive_run_activity_repository.dart';
import 'package:mingalar_un/features/run/domain/entities/run_activity.dart';

void main() {
  test('Hive repositories survive closing and reopening their boxes', () async {
    final directory = await Directory.systemTemp.createTemp('mingalar_hive_');
    Hive.init(directory.path);
    Hive.registerAdapter(UserProfileHiveAdapter());
    Hive.registerAdapter(RunActivityHiveAdapter());

    try {
      await Hive.openBox<UserProfileHiveModel>(HiveBoxNames.profile);
      await Hive.openBox<RunActivityHiveModel>(HiveBoxNames.runActivities);

      final profileRepository = HiveProfileRepository.openedBox();
      final runRepository = HiveRunActivityRepository.openedBox();
      const profile = UserProfile(
        name: 'Mya Mya',
        phoneNumber: '09 123 456 789',
        tier: 'Gold',
        ionPoints: 42,
      );
      final activity = RunActivity(
        id: 'persisted-run',
        startedAt: DateTime(2026, 8, 30, 6, 30),
        calories: 210,
        distanceKilometers: 4.75,
        duration: const Duration(minutes: 28),
        pacePerKilometer: const Duration(minutes: 5, seconds: 54),
        steps: 5800,
      );

      await profileRepository.saveProfile(profile);
      await runRepository.saveActivity(activity);
      await Hive.close();

      await Hive.openBox<UserProfileHiveModel>(HiveBoxNames.profile);
      await Hive.openBox<RunActivityHiveModel>(HiveBoxNames.runActivities);

      final restoredProfile = await HiveProfileRepository.openedBox()
          .getProfile();
      final restoredRuns = await HiveRunActivityRepository.openedBox()
          .getActivities();

      expect(restoredProfile?.name, profile.name);
      expect(restoredProfile?.ionPoints, profile.ionPoints);
      expect(restoredRuns.single.id, activity.id);
      expect(restoredRuns.single.distanceKilometers, 4.75);
      expect(restoredRuns.single.steps, 5800);
    } finally {
      await Hive.close();
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    }
  });
}
