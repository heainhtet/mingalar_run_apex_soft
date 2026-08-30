import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/run_calendar_models.dart';

final runCurrentDateProvider = Provider<DateTime>((ref) => DateTime.now());

final selectedRunTabProvider = StateProvider.autoDispose<int>((ref) => 0);

final runCalendarVisibleMonthProvider = StateProvider.autoDispose<DateTime>((
  ref,
) {
  final today = ref.watch(runCurrentDateProvider);
  return DateTime(today.year, today.month);
});

final runActivitiesProvider = Provider<List<RunActivity>>((ref) {
  final now = ref.watch(runCurrentDateProvider);
  final today = DateTime(now.year, now.month, now.day);
  final daysSinceSunday = today.weekday % DateTime.daysPerWeek;
  final weekStart = today.subtract(Duration(days: daysSinceSunday));
  final previousRunDay = daysSinceSunday == 0
      ? today
      : today.subtract(const Duration(days: 1));

  return [
    RunActivity(
      startedAt: DateTime(
        previousRunDay.year,
        previousRunDay.month,
        previousRunDay.day,
        4,
        19,
      ),
      calories: 120,
      distanceKilometers: 1.4,
      duration: const Duration(minutes: 45),
      pacePerKilometer: const Duration(minutes: 7, seconds: 30),
    ),
    RunActivity(
      startedAt: DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day,
        21,
        34,
      ),
      calories: 98,
      distanceKilometers: 1.1,
      duration: const Duration(minutes: 32),
      pacePerKilometer: const Duration(minutes: 8, seconds: 5),
    ),
  ];
});

final runCalendarDaysProvider = Provider<List<CalendarDay>>((ref) {
  final now = ref.watch(runCurrentDateProvider);
  final today = DateTime(now.year, now.month, now.day);
  final activities = ref.watch(runActivitiesProvider);
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
