import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';

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
            child: _WeekDayIndicator(
              label: _weekdayKeys[index].tr(),
              isToday: isToday,
            ),
          ),
        );
      }),
    );
  }
}

class _WeekDayIndicator extends StatelessWidget {
  const _WeekDayIndicator({required this.label, required this.isToday});

  final String label;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: (isToday ? AppTextStyles.bold() : AppTextStyles.regular())
              .white
              .s(10)
              .copyWith(
                color: AppColors.defaultPrimaryText,
                height: 1,
                letterSpacing: -0.31,
              ),
        ),
        Gap(10),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isToday
                  ? AppColors.activeIconColor
                  : AppColors.inactiveIconColor.withAlpha(130),
              width: 3,
            ),
          ),
        ),
      ],
    );
  }
}
