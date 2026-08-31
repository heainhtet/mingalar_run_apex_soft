import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/run_calendar_models.dart';

class CalendarIndicator extends StatelessWidget {
  const CalendarIndicator({
    super.key,
    required this.status,
    this.backgroundColor = AppColors.topHeaderBackground,
    this.todayBorderColor = AppColors.white,
  });

  final RunCalendarStatus status;
  final Color backgroundColor;
  final Color todayBorderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: 16,
      height: 16,
      decoration: switch (status) {
        RunCalendarStatus.completeRecord => BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          border: Border.all(color: AppColors.completeRecordColor, width: 3),
        ),
        RunCalendarStatus.today => BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          border: Border.all(color: todayBorderColor, width: 3),
        ),
        RunCalendarStatus.noRecord => BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          border: Border.all(
            color: AppColors.inactiveIconColor.withAlpha(130),
            width: 3,
          ),
        ),
      },
    );
  }
}
