import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';
import '../models/run_calendar_models.dart';
import 'run_calendar_day.dart';

class RunCalendarMonthGrid extends StatelessWidget {
  const RunCalendarMonthGrid({
    super.key,
    required this.days,
    required this.leadingDays,
    required this.localizations,
  });

  final List<CalendarDay> days;
  final int leadingDays;
  final MaterialLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryButtonColor.withAlpha(12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
        child: Column(
          children: [
            Row(
              children: List.generate(DateTime.daysPerWeek, (index) {
                return Expanded(
                  child: Text(
                    localizations.narrowWeekdays[index],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.medium()
                        .s(10)
                        .copyWith(
                          color: AppColors.primaryButtonColor,
                          height: 1,
                        ),
                  ),
                );
              }),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: DateTime.daysPerWeek,
                childAspectRatio: 0.8,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: leadingDays + days.length,
              itemBuilder: (context, index) {
                if (index < leadingDays) return const SizedBox.shrink();
                return RunCalendarDay(
                  day: days[index - leadingDays],
                  textColor: AppColors.cardLabelText,
                  indicatorBackgroundColor: AppColors.white,
                  todayBorderColor: AppColors.tabIndicatorColor,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
