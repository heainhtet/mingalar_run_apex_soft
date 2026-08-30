import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';

class WeekDayIndicator extends StatelessWidget {
  const WeekDayIndicator({
    super.key,
    required this.label,
    required this.isToday,
  });

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
