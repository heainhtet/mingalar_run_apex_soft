import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../data/repositories/hive_run_activity_repository.dart';
import '../../domain/entities/run_day_stat.dart';
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
    try {
      await _repository.saveActivity(activity);
      state = AsyncData(await _repository.getActivities());
    } catch (error, stackTrace) {
      logger.e(
        'Unable to save completed run',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> recordCompletedRun({
    required DateTime startedAt,
    required int calories,
    required double distanceKilometers,
    required Duration duration,
    Duration? paceDuration,
    Duration? pacePerKilometer,
    required int steps,
  }) async {
    if (!distanceKilometers.isFinite || distanceKilometers < 0) {
      throw ArgumentError.value(
        distanceKilometers,
        'distanceKilometers',
        'Distance must be a finite, non-negative number.',
      );
    }
    if (calories < 0 ||
        steps < 0 ||
        duration.isNegative ||
        paceDuration?.isNegative == true) {
      throw ArgumentError('Run measurements cannot be negative.');
    }

    final effectivePaceDuration = paceDuration ?? duration;
    final pace = pacePerKilometer != null && pacePerKilometer >= Duration.zero
        ? pacePerKilometer
        : distanceKilometers == 0
        ? Duration.zero
        : Duration(
            milliseconds:
                (effectivePaceDuration.inMilliseconds / distanceKilometers)
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

final selectedRunTabProvider = NotifierProvider<SelectedRunTabController, int>(
  SelectedRunTabController.new,
);

class SelectedRunTabController extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) {
    if (index != state) state = index;
  }
}

final runCalendarDaysProvider = Provider<List<CalendarDay>>((ref) {
  final now = ref.watch(runCurrentDateProvider);
  final today = DateTime(now.year, now.month, now.day);
  final activities = ref.watch(runActivitiesProvider).value ?? const [];
  final completedDates = activities
      .map((activity) => _dateOnly(activity.startedAt))
      .toSet();
  final daysSinceSunday = today.weekday % DateTime.daysPerWeek;
  final currentWeekStart = today.subtract(Duration(days: daysSinceSunday));
  final firstDay = currentWeekStart.subtract(
    const Duration(days: DateTime.daysPerWeek),
  );

  return List.generate(14, (index) {
    final date = firstDay.add(Duration(days: index));
    final hasCompletedRun = completedDates.contains(date);
    final status = hasCompletedRun
        ? RunCalendarStatus.completeRecord
        : isSameCalendarDate(date, today)
        ? RunCalendarStatus.today
        : RunCalendarStatus.noRecord;

    return CalendarDay(date: date, status: status);
  });
});

final runCurrentMonthCalendarDaysProvider = Provider<List<CalendarDay>>((ref) {
  final now = ref.watch(runCurrentDateProvider);
  final today = DateTime(now.year, now.month, now.day);
  final activities = ref.watch(runActivitiesProvider).value ?? const [];
  final completedDates = activities
      .map((activity) => _dateOnly(activity.startedAt))
      .toSet();
  final daysInMonth = DateTime(today.year, today.month + 1, 0).day;

  return List.generate(daysInMonth, (index) {
    final date = DateTime(today.year, today.month, index + 1);
    final hasCompletedRun = completedDates.contains(date);
    final status = hasCompletedRun
        ? RunCalendarStatus.completeRecord
        : isSameCalendarDate(date, today)
        ? RunCalendarStatus.today
        : RunCalendarStatus.noRecord;
    return CalendarDay(date: date, status: status);
  });
});

final runLastThreeDaysProvider = Provider<List<RunDayStat>>((ref) {
  return ref.watch(runRecentDaysProvider(3));
});

final runLastSevenDaysProvider = Provider<List<RunDayStat>>((ref) {
  return ref.watch(runRecentDaysProvider(DateTime.daysPerWeek));
});

final runAllHistoryDaysProvider = Provider<List<RunDayStat>>((ref) {
  final activities = ref.watch(runActivitiesProvider).value ?? const [];
  if (activities.isEmpty) return ref.watch(runLastSevenDaysProvider);

  final activitiesByDay = _groupActivitiesByDay(activities);
  final dates = activitiesByDay.keys.toList()
    ..sort((first, second) => second.compareTo(first));

  return dates
      .map((date) => _aggregateRunDay(date, activitiesByDay[date] ?? const []))
      .toList();
});

final runRecentDaysProvider = Provider.family<List<RunDayStat>, int>((
  ref,
  dayCount,
) {
  final now = ref.watch(runCurrentDateProvider);
  final today = DateTime(now.year, now.month, now.day);
  final activities = ref.watch(runActivitiesProvider).value ?? const [];
  final activitiesByDay = _groupActivitiesByDay(activities);

  final days = List.generate(
    dayCount,
    (index) => today.subtract(Duration(days: index)),
  );

  return days
      .map((day) => _aggregateRunDay(day, activitiesByDay[day] ?? const []))
      .toList();
});

RunDayStat _aggregateRunDay(DateTime day, List<RunActivity> dayActivities) {
  if (dayActivities.isEmpty) {
    return RunDayStat(date: day, hasActivity: false);
  }

  var totalCalories = 0;
  var totalDistance = 0.0;
  var totalDuration = Duration.zero;
  var totalSteps = 0;

  for (final activity in dayActivities) {
    totalCalories += activity.calories;
    totalDistance += activity.distanceKilometers;
    totalDuration += activity.duration;
    totalSteps += activity.steps;
  }

  final aggregatePace = totalDistance <= 0
      ? null
      : Duration(
          milliseconds: (totalDuration.inMilliseconds / totalDistance).round(),
        );

  return RunDayStat(
    date: day,
    hasActivity: true,
    calories: totalCalories,
    distanceKilometers: totalDistance,
    duration: totalDuration,
    pacePerKilometer: aggregatePace,
    steps: totalSteps,
    activityCount: dayActivities.length,
  );
}

Map<DateTime, List<RunActivity>> _groupActivitiesByDay(
  List<RunActivity> activities,
) {
  final result = <DateTime, List<RunActivity>>{};
  for (final activity in activities) {
    result.putIfAbsent(_dateOnly(activity.startedAt), () => []).add(activity);
  }
  return result;
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
