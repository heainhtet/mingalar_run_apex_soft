import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';
import '../models/profile_models.dart';

class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({super.key, required this.metric});

  final ProfileSummaryMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 101,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SummaryIcon(type: metric.type),
              const Gap(8),
              Expanded(
                child: Text(
                  metric.labelKey.tr(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.regular().black
                      .s(10)
                      .copyWith(
                        color: AppColors.secondaryText(context),
                        height: 12 / 10,
                        letterSpacing: 0,
                      ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text.rich(
            TextSpan(
              text: metric.value,
              children: [
                TextSpan(
                  text: metric.unit,
                  style: AppTextStyles.semiBold().black
                      .s(14)
                      .copyWith(
                        color: AppColors.primaryText(context),
                        height: 1,
                        letterSpacing: 0,
                      ),
                ),
              ],
            ),
            maxLines: 1,
            style: AppTextStyles.semiBold().black
                .s(28)
                .copyWith(
                  color: AppColors.primaryText(context),
                  height: 32 / 28,
                  letterSpacing: 0,
                ),
          ),
        ],
      ),
    );
  }
}

class _SummaryIcon extends StatelessWidget {
  const _SummaryIcon({required this.type});

  final ProfileSummaryType type;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(type);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [style.startColor, style.endColor],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(style.icon, size: style.iconSize, color: style.iconColor),
    );
  }

  _SummaryIconStyle _styleFor(ProfileSummaryType type) {
    return switch (type) {
      ProfileSummaryType.totalRuns => const _SummaryIconStyle(
        icon: Icons.directions_run_rounded,
        iconColor: AppColors.totalRunIconColor,
        startColor: AppColors.totalRunIconGradientStart,
        endColor: AppColors.totalRunIconGradientEnd,
        iconSize: 23,
      ),
      ProfileSummaryType.longestDistance => const _SummaryIconStyle(
        icon: Icons.location_on_rounded,
        iconColor: AppColors.distanceIconColor,
        startColor: AppColors.distanceIconGradientStart,
        endColor: AppColors.distanceIconGradientEnd,
        iconSize: 23,
      ),
      ProfileSummaryType.totalCalories => const _SummaryIconStyle(
        icon: Icons.local_fire_department_rounded,
        iconColor: AppColors.caloriesIconColor,
        startColor: AppColors.caloriesIconGradientStart,
        endColor: AppColors.caloriesIconGradientEnd,
        iconSize: 21,
      ),
      ProfileSummaryType.bestPace => const _SummaryIconStyle(
        icon: Icons.bolt_rounded,
        iconColor: AppColors.paceIconColor,
        startColor: AppColors.paceIconGradientStart,
        endColor: AppColors.paceIconGradientEnd,
        iconSize: 23,
      ),
    };
  }
}

class _SummaryIconStyle {
  const _SummaryIconStyle({
    required this.icon,
    required this.iconColor,
    required this.startColor,
    required this.endColor,
    required this.iconSize,
  });

  final IconData icon;
  final Color iconColor;
  final Color startColor;
  final Color endColor;
  final double iconSize;
}
