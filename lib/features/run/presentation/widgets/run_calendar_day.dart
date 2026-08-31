import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';
import '../models/run_calendar_models.dart';
import 'calendar_indicator.dart';

class RunCalendarDay extends StatelessWidget {
  const RunCalendarDay({
    super.key,
    required this.day,
    this.textColor = AppColors.defaultPrimaryText,
    this.indicatorBackgroundColor = AppColors.topHeaderBackground,
    this.todayBorderColor = AppColors.white,
  });

  final CalendarDay day;
  final Color textColor;
  final Color indicatorBackgroundColor;
  final Color todayBorderColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          day.label,
          style: AppTextStyles.regular().white
              .s(10)
              .copyWith(color: textColor, height: 1, letterSpacing: -0.31),
        ),
        const Gap(8),
        CalendarIndicator(
          status: day.status,
          backgroundColor: indicatorBackgroundColor,
          todayBorderColor: todayBorderColor,
        ),
      ],
    );
  }
}
