import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/home_section_header.dart';
import '../models/run_calendar_models.dart';
import 'run_calendar_day.dart';
import 'run_calendar_legend.dart';

class RunCalendarSection extends StatelessWidget {
  const RunCalendarSection({
    super.key,
    required this.days,
    required this.onSeeAll,
  });

  final List<CalendarDay> days;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(
          title: 'runScreen.calendar'.tr(),
          actionLabel: 'runScreen.seeAll'.tr(),
          titleColor: AppColors.defaultPrimaryText,
          actionColor: AppColors.defaultPrimaryText,
          onActionPressed: onSeeAll,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.topHeaderBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.calenderCardBorderColor,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              _buildWeekRow(days.sublist(0, 7)),
              const SizedBox(height: 18),
              _buildWeekRow(days.sublist(7, 14)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const RunCalendarLegend(),
      ],
    );
  }

  Widget _buildWeekRow(List<CalendarDay> week) {
    return Row(
      children: week
          .map((day) => Expanded(child: RunCalendarDay(day: day)))
          .toList(),
    );
  }
}
