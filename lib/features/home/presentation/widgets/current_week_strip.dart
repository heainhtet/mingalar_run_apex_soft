import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mingalar_un/features/home/presentation/widgets/week_day_indicator.dart';

class CurrentWeekStrip extends StatelessWidget {
  const CurrentWeekStrip({super.key, required this.currentDate});

  final DateTime currentDate;

  static const _weekdayKeys = [
    'homeScreen.weekdays.sun',
    'homeScreen.weekdays.mon',
    'homeScreen.weekdays.tue',
    'homeScreen.weekdays.wed',
    'homeScreen.weekdays.thu',
    'homeScreen.weekdays.fri',
    'homeScreen.weekdays.sat',
  ];

  @override
  Widget build(BuildContext context) {
    final startOfWeek = currentDate.subtract(
      Duration(days: currentDate.weekday % DateTime.daysPerWeek),
    );
    final week = List.generate(
      DateTime.daysPerWeek,
      (index) => startOfWeek.add(Duration(days: index)),
    );

    return Row(
      children: List.generate(week.length, (index) {
        final day = week[index];
        final isToday = DateUtils.isSameDay(day, currentDate);

        return Expanded(
          child: Semantics(
            label: '${_weekdayKeys[index].tr()}, ${day.day}',
            selected: isToday,
            child: WeekDayIndicator(
              label: _weekdayKeys[index].tr(),
              isToday: isToday,
            ),
          ),
        );
      }),
    );
  }
}
