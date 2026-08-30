import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/repositories/hive_run_activity_repository.dart';
import '../../domain/repositories/run_activity_repository.dart';
import '../models/run_calendar_models.dart';

final runActivityRepositoryProvider = Provider<RunActivityRepository>((ref) {
  return HiveRunActivityRepository.openedBox();
});

final runActivitiesProvider =
    AsyncNotifierProvider<RunActivitiesController, List<RunActivity>>(
      RunActivitiesController.new,
    );

class RunActivitiesController extends AsyncNotifier<List<RunActivity>> {
  RunActivityRepository get _repository =>
      ref.read(runActivityRepositoryProvider);

  @override
  Future<List<RunActivity>> build() => _repository.getActivities();

  Future<void> saveActivity(RunActivity activity) async {
    await _repository.saveActivity(activity);
    state = AsyncData(await _repository.getActivities());
  }

  Future<void> recordCompletedRun({
    required DateTime startedAt,
    required int calories,
    required double distanceKilometers,
    required Duration duration,
    required int steps,
  }) async {
    if (!distanceKilometers.isFinite || distanceKilometers < 0) {
      throw ArgumentError.value(
        distanceKilometers,
        'distanceKilometers',
        'Distance must be a finite, non-negative number.',
      );
    }
    if (calories < 0 || steps < 0 || duration.isNegative) {
      throw ArgumentError('Run measurements cannot be negative.');
    }

    final pace = distanceKilometers == 0
        ? Duration.zero
        : Duration(
            milliseconds: (duration.inMilliseconds / distanceKilometers)
                .round(),
          );
    final activity = RunActivity(
      id: '${startedAt.microsecondsSinceEpoch}-${duration.inMilliseconds}',
      startedAt: startedAt,
      calories: calories,
      distanceKilometers: distanceKilometers,
      duration: duration,
      pacePerKilometer: pace,
      steps: steps,
    );

    await saveActivity(activity);
  }

  Future<void> deleteActivity(String id) async {
    await _repository.deleteActivity(id);
    state = AsyncData(await _repository.getActivities());
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getActivities);
  }
}

final runCurrentDateProvider = Provider<DateTime>((ref) => DateTime.now());

final runWeekActivitiesProvider = Provider<List<RunActivity>>((ref) {
  final now = ref.watch(runCurrentDateProvider);
  final today = DateTime(now.year, now.month, now.day);
  final weekStart = today.subtract(
    Duration(days: today.weekday % DateTime.daysPerWeek),
  );
  final weekEnd = weekStart.add(const Duration(days: DateTime.daysPerWeek));
  final activities = ref.watch(runActivitiesProvider).value ?? const [];

  return activities.where((activity) {
    return !activity.startedAt.isBefore(weekStart) &&
        activity.startedAt.isBefore(weekEnd);
  }).toList();
});

final selectedRunTabProvider = StateProvider.autoDispose<int>((ref) => 0);

final runCalendarVisibleMonthProvider = StateProvider.autoDispose<DateTime>((
  ref,
) {
  final today = ref.watch(runCurrentDateProvider);
  return DateTime(today.year, today.month);
});

final runCalendarDaysProvider = Provider<List<CalendarDay>>((ref) {
  final now = ref.watch(runCurrentDateProvider);
  final today = DateTime(now.year, now.month, now.day);
  final activities = ref.watch(runActivitiesProvider).value ?? const [];
  final completedDates = activities.map((activity) => activity.startedAt);
  final daysSinceSunday = today.weekday % DateTime.daysPerWeek;
  final firstDay = today.subtract(Duration(days: daysSinceSunday));

  return List.generate(14, (index) {
    final date = firstDay.add(Duration(days: index));
    final status = isSameCalendarDate(date, today)
        ? RunCalendarStatus.today
        : completedDates.any((completed) => isSameCalendarDate(completed, date))
        ? RunCalendarStatus.completeRecord
        : RunCalendarStatus.noRecord;

    return CalendarDay(date: date, status: status);
  });
});
