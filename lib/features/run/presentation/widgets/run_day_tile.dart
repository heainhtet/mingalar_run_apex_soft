import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/assets_constant.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/measurement_formatter.dart';
import '../../../../core/utils/text_extensions.dart';
import '../../domain/entities/run_day_stat.dart';
import 'stat_item.dart';

class RunDayTile extends StatelessWidget {
  const RunDayTile({
    super.key,
    required this.day,
    this.color = AppColors.topHeaderBackground,
    this.showShareAction = false,
    this.shareLabel = 'Share',
    this.onShare,
    this.onTap,
  });

  final RunDayStat day;
  final Color color;
  final bool showShareAction;
  final String shareLabel;
  final ValueChanged<Rect?>? onShare;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final paceText = day.pacePerKilometer == null
        ? '0:00'
        : _formatPace(day.pacePerKilometer!);

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatDate(day.date),
                      style: AppTextStyles.medium().white
                          .s(12)
                          .copyWith(
                            color: AppColors.defaultPrimaryText,
                            height: 16 / 12,
                            letterSpacing: 0,
                          ),
                    ),
                  ),
                  if (day.hasActivity) ...[
                    Text(
                      'runScreen.completeRecord'.tr(),

                      style: AppTextStyles.semiBold().white
                          .s(12)
                          .copyWith(
                            color: AppColors.completeRecordColor,
                            height: 1,
                            letterSpacing: 0,
                          ),
                    ),
                    const Gap(4),
                  ],
                  if (showShareAction)
                    _ShareAction(
                      label: shareLabel,
                      onPressed: day.hasActivity ? onShare : null,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  StatItem(
                    assetPath: AssetsConstant.runCal,
                    value: '${day.calories} cal',
                  ),
                  StatItem(
                    assetPath: AssetsConstant.runMapPin,
                    value: MeasurementFormatter.distance(
                      day.distanceKilometers,
                    ).label,
                  ),
                  StatItem(
                    assetPath: AssetsConstant.runClock,
                    value: '${day.duration.inMinutes} min',
                  ),
                  StatItem(
                    assetPath: AssetsConstant.runShoe,
                    value: '$paceText min/km',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final difference = today.difference(target).inDays;

    if (difference == 0) return 'runScreen.today'.tr();
    if (difference == 1) return 'runScreen.yesterday'.tr();
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatPace(Duration pace) {
    final seconds = pace.inSeconds.remainder(Duration.secondsPerMinute);
    return '${pace.inMinutes}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _ShareAction extends StatelessWidget {
  const _ShareAction({required this.label, this.onPressed});

  final String label;
  final ValueChanged<Rect?>? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed == null ? null : () => onPressed!(_originFor(context)),
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
                    color: onPressed == null
                        ? AppColors.defaultPrimaryText.withValues(alpha: 0.4)
                        : AppColors.defaultPrimaryText,
                    height: 1,
                    letterSpacing: 0,
                  ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.share_outlined,
              size: 12,
              color: onPressed == null
                  ? AppColors.defaultPrimaryText.withValues(alpha: 0.4)
                  : AppColors.defaultPrimaryText,
            ),
          ],
        ),
      ),
    );
  }

  Rect? _originFor(BuildContext context) {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }
}
