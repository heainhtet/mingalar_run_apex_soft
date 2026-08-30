import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/assets_constant.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';
import '../models/run_calendar_models.dart';
import 'stat_item.dart';

class RunActivityTile extends StatelessWidget {
  const RunActivityTile({
    super.key,
    required this.activity,
    this.color = AppColors.topHeaderBackground,
  });

  final RunActivity activity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('dd MMM yyyy, hh:mm a').format(activity.startedAt),
            style: AppTextStyles.medium().white
                .s(12)
                .copyWith(
                  color: AppColors.defaultPrimaryText,
                  height: 16 / 12,
                  letterSpacing: 0,
                ),
          ),

          const Gap(12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StatItem(
                assetPath: AssetsConstant.runCal,
                value: '${activity.calories} cal',
              ),
              StatItem(
                assetPath: AssetsConstant.runMapPin,
                value: '${activity.distanceKilometers.toStringAsFixed(1)} km',
              ),
              StatItem(
                assetPath: AssetsConstant.runClock,
                value: '${activity.duration.inMinutes} min',
              ),
              StatItem(
                assetPath: AssetsConstant.runShoe,
                value: '${_formatPace(activity.pacePerKilometer)} min/km',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPace(Duration pace) {
    final seconds = pace.inSeconds.remainder(Duration.secondsPerMinute);
    return '${pace.inMinutes}:${seconds.toString().padLeft(2, '0')}';
  }
}
