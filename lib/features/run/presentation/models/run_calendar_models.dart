enum RunCalendarStatus { completeRecord, today, noRecord }

class CalendarDay {
  const CalendarDay({required this.date, required this.status});

  final DateTime date;
  final RunCalendarStatus status;

  String get label => date.day.toString().padLeft(2, '0');
}

class RunActivity {
  const RunActivity({
    required this.startedAt,
    required this.calories,
    required this.distanceKilometers,
    required this.duration,
    required this.pacePerKilometer,
  });

  final DateTime startedAt;
  final int calories;
  final double distanceKilometers;
  final Duration duration;
  final Duration pacePerKilometer;
}

bool isSameCalendarDate(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
