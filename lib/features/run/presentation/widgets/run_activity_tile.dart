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
    this.showShareAction = false,
    this.shareLabel = 'Share',
    this.onShare,
  });

  final RunActivity activity;
  final Color color;
  final bool showShareAction;
  final String shareLabel;
  final VoidCallback? onShare;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(activity.startedAt),
                  style: AppTextStyles.medium().white
                      .s(12)
                      .copyWith(
                        color: AppColors.defaultPrimaryText,
                        height: 16 / 12,
                        letterSpacing: 0,
                      ),
                ),
              ),
              if (showShareAction)
                _ShareAction(label: shareLabel, onPressed: onShare),
            ],
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

class _ShareAction extends StatelessWidget {
  const _ShareAction({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.semiBold().white
                  .s(12)
                  .copyWith(
                    color: AppColors.defaultPrimaryText,
                    height: 1,
                    letterSpacing: 0,
                  ),
            ),
            const Gap(4),
            const Icon(
              Icons.share_outlined,
              size: 12,
              color: AppColors.defaultPrimaryText,
            ),
          ],
        ),
      ),
    );
  }
}
