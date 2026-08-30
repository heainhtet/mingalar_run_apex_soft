export '../../domain/entities/run_activity.dart';

enum RunCalendarStatus { completeRecord, today, noRecord }

class CalendarDay {
  const CalendarDay({required this.date, required this.status});

  final DateTime date;
  final RunCalendarStatus status;

  String get label => date.day.toString().padLeft(2, '0');
}

bool isSameCalendarDate(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
