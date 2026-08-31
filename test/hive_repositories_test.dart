import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mingalar_un/core/database/app_preferences.dart';
import 'package:mingalar_un/core/database/hive_database.dart';
import 'package:mingalar_un/features/profile/data/models/user_profile_hive_model.dart';
import 'package:mingalar_un/features/profile/data/repositories/hive_profile_repository.dart';
import 'package:mingalar_un/features/profile/domain/entities/user_profile.dart';
import 'package:mingalar_un/features/run/data/models/run_activity_hive_model.dart';
import 'package:mingalar_un/features/run/data/models/run_session_hive_model.dart';
import 'package:mingalar_un/features/run/data/repositories/hive_run_activity_repository.dart';
import 'package:mingalar_un/features/run/data/repositories/hive_run_session_repository.dart';
import 'package:mingalar_un/features/run/domain/entities/run_activity.dart';
import 'package:mingalar_un/features/run/domain/entities/run_session_snapshot.dart';
import 'package:mingalar_un/features/run/domain/entities/run_stage.dart';

void main() {
  test('Hive repositories survive closing and reopening their boxes', () async {
    final directory = await Directory.systemTemp.createTemp('mingalar_hive_');
    Hive.init(directory.path);
    Hive.registerAdapter(UserProfileHiveAdapter());
    Hive.registerAdapter(RunActivityHiveAdapter());
    Hive.registerAdapter(RunSessionHiveAdapter());

    try {
      await Hive.openBox<UserProfileHiveModel>(HiveBoxNames.profile);
      await Hive.openBox<RunActivityHiveModel>(HiveBoxNames.runActivities);
      await Hive.openBox<RunSessionHiveModel>(HiveBoxNames.runSession);
      await Hive.openBox<bool>(HiveBoxNames.preferences);

      final profileRepository = HiveProfileRepository.openedBox();
      final runRepository = HiveRunActivityRepository.openedBox();
      final sessionRepository = HiveRunSessionRepository.openedBox();
      final preferences = HiveAppPreferences.openedBox();
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
      await preferences.completeOnboarding();
      await runRepository.saveActivity(activity);
      await sessionRepository.saveActiveSession(
        RunSessionSnapshot(
          startedAt: activity.startedAt,
          elapsed: const Duration(minutes: 8),
          movingElapsed: const Duration(minutes: 6),
          distanceKilometers: 1.25,
          caloriesExact: 72.5,
          steps: 1600,
          stage: RunStage.jogging,
        ),
      );
      await Hive.close();

      await Hive.openBox<UserProfileHiveModel>(HiveBoxNames.profile);
      await Hive.openBox<RunActivityHiveModel>(HiveBoxNames.runActivities);
      await Hive.openBox<RunSessionHiveModel>(HiveBoxNames.runSession);
      await Hive.openBox<bool>(HiveBoxNames.preferences);

      final restoredProfile = await HiveProfileRepository.openedBox()
          .getProfile();
      final restoredRuns = await HiveRunActivityRepository.openedBox()
          .getActivities();
      final restoredSession = HiveRunSessionRepository.openedBox()
          .readActiveSession();
      final restoredPreferences = HiveAppPreferences.openedBox();

      expect(restoredProfile?.name, profile.name);
      expect(restoredProfile?.ionPoints, profile.ionPoints);
      expect(restoredRuns.single.id, activity.id);
      expect(restoredRuns.single.distanceKilometers, 4.75);
      expect(restoredRuns.single.steps, 5800);
      expect(restoredSession?.elapsed, const Duration(minutes: 8));
      expect(restoredSession?.movingElapsed, const Duration(minutes: 6));
      expect(restoredSession?.distanceKilometers, 1.25);
      expect(restoredSession?.steps, 1600);
      expect(restoredSession?.stage, RunStage.jogging);
      expect(restoredPreferences.hasCompletedOnboarding, isTrue);

      await HiveDatabase.clearAllUserData();

      expect(await HiveProfileRepository.openedBox().getProfile(), isNull);
      expect(
        await HiveRunActivityRepository.openedBox().getActivities(),
        isEmpty,
      );
      expect(HiveRunSessionRepository.openedBox().readActiveSession(), isNull);
      expect(HiveAppPreferences.openedBox().hasCompletedOnboarding, isFalse);
    } finally {
      await Hive.close();
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    }
  });
}
