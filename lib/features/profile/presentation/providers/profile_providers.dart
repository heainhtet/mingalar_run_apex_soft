import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../../../core/utils/measurement_formatter.dart';
import '../../../run/domain/entities/run_activity.dart';
import '../../../run/presentation/providers/run_providers.dart';
import '../../data/repositories/hive_profile_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/profile_models.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return HiveProfileRepository.openedBox();
});

final profileProvider = AsyncNotifierProvider<ProfileController, ProfileState>(
  ProfileController.new,
);

class ProfileController extends AsyncNotifier<ProfileState> {
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  @override
  Future<ProfileState> build() async {
    final user = await _repository.getProfile();
    return ProfileState(user: user);
  }

  Future<void> saveProfile({
    required String name,
    required String phoneNumber,
  }) async {
    final current = state.value ?? const ProfileState();
    state = AsyncData(current.copyWith(isSaving: true));

    final user = current.user == null
        ? UserProfile.newRunner(
            name: name.trim(),
            phoneNumber: phoneNumber.trim(),
          )
        : UserProfile(
            name: name.trim(),
            phoneNumber: phoneNumber.trim(),
            tier: current.user!.tier,
            ionPoints: current.user!.ionPoints,
          );

    try {
      await _repository.saveProfile(user);
      state = AsyncData(ProfileState(user: user));
      logger.i('Local runner profile saved');
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      logger.e(
        'Unable to save local runner profile',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> deleteProfile() async {
    await _repository.deleteProfile();
    state = const AsyncData(ProfileState());
    logger.i('Local runner profile deleted');
  }
}

final profileSummaryProvider = Provider<List<ProfileSummaryMetric>>((ref) {
  final activities = ref.watch(runActivitiesProvider).value ?? const [];
  final summary = _RunSummary.fromActivities(activities);
  final longestDistance = MeasurementFormatter.distance(
    summary.longestDistanceKilometers,
  );

  return [
    ProfileSummaryMetric(
      type: ProfileSummaryType.totalRuns,
      labelKey: 'profileScreen.totalRuns',
      value: summary.totalRuns.toString(),
    ),
    ProfileSummaryMetric(
      type: ProfileSummaryType.longestDistance,
      labelKey: 'profileScreen.longestDistance',
      value: longestDistance.value,
      unit: longestDistance.unit,
    ),
    ProfileSummaryMetric(
      type: ProfileSummaryType.totalCalories,
      labelKey: 'profileScreen.totalCalories',
      value: summary.totalCalories.toString(),
      unit: 'kcal',
    ),
    ProfileSummaryMetric(
      type: ProfileSummaryType.bestPace,
      labelKey: 'profileScreen.bestPace',
      value: _formatPace(summary.bestPace),
      unit: '/km',
    ),
  ];
});

class _RunSummary {
  const _RunSummary({
    required this.totalRuns,
    required this.longestDistanceKilometers,
    required this.totalCalories,
    required this.bestPace,
  });

  factory _RunSummary.fromActivities(List<RunActivity> activities) {
    var longestDistance = 0.0;
    var totalCalories = 0;
    Duration? bestPace;

    for (final activity in activities) {
      if (activity.distanceKilometers > longestDistance) {
        longestDistance = activity.distanceKilometers;
      }
      totalCalories += activity.calories;
      if (activity.pacePerKilometer > Duration.zero &&
          (bestPace == null || activity.pacePerKilometer < bestPace)) {
        bestPace = activity.pacePerKilometer;
      }
    }

    return _RunSummary(
      totalRuns: activities.length,
      longestDistanceKilometers: longestDistance,
      totalCalories: totalCalories,
      bestPace: bestPace,
    );
  }

  final int totalRuns;
  final double longestDistanceKilometers;
  final int totalCalories;
  final Duration? bestPace;
}

String _formatPace(Duration? pace) {
  if (pace == null) return '0:00';
  final seconds = pace.inSeconds.remainder(Duration.secondsPerMinute);
  return '${pace.inMinutes}:${seconds.toString().padLeft(2, '0')}';
}
