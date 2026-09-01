import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';

class RunCalendarMonthOverview extends StatelessWidget {
  const RunCalendarMonthOverview({
    super.key,
    required this.completedDays,
    required this.totalDays,
  });

  final int completedDays;
  final int totalDays;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _OverviewTile(
            icon: Icons.check_circle_outline_rounded,
            value: completedDays.toString(),
            label: 'runScreen.completedDays'.tr(),
            iconColor: AppColors.completeRecordColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _OverviewTile(
            icon: Icons.date_range_rounded,
            value: totalDays.toString(),
            label: 'runScreen.daysThisMonth'.tr(),
            iconColor: AppColors.primaryButtonColor,
          ),
        ),
      ],
    );
  }
}

class _OverviewTile extends StatelessWidget {
  const _OverviewTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryButtonColor.withAlpha(13),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: AppTextStyles.semiBold()
                        .s(17)
                        .copyWith(
                          color: AppColors.primaryText(context),
                          height: 1,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.regular()
                        .s(9)
                        .copyWith(
                          color: AppColors.secondaryText(context),
                          height: 1,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
