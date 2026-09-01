import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/measurement_formatter.dart';
import '../../../../core/utils/text_extensions.dart';
import '../../domain/entities/run_day_stat.dart';
import '../models/run_calendar_models.dart';
import '../providers/run_providers.dart';

Future<void> showRunActivityDetailDialog(
  BuildContext context, {
  required RunDayStat day,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppColors.black.withAlpha(153),
    transitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (context, animation, secondaryAnimation) {
      return RunActivityDetailDialog(day: day);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.88, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class RunActivityDetailDialog extends ConsumerWidget {
  const RunActivityDetailDialog({super.key, required this.day});

  final RunDayStat day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allActivities = ref.watch(runActivitiesProvider).value ?? const [];
    final activities =
        allActivities
            .where(
              (activity) => isSameCalendarDate(activity.startedAt, day.date),
            )
            .toList()
          ..sort(
            (first, second) => second.startedAt.compareTo(first.startedAt),
          );

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 700),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: DecoratedBox(
            decoration: BoxDecoration(color: AppColors.surface(context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DetailHeader(
                  date: day.date,
                  hasActivity: day.hasActivity,
                  onClose: () => Navigator.of(context).pop(),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: day.hasActivity
                        ? _ActivityContent(day: day, activities: activities)
                        : const _EmptyActivityContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.date,
    required this.hasActivity,
    required this.onClose,
  });

  final DateTime date;
  final bool hasActivity;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.runGradientStart, AppColors.runGradientEnd],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 10, 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'runScreen.activityDetails'.tr(),
                    style: AppTextStyles.semiBold().white
                        .s(20)
                        .copyWith(
                          color: AppColors.defaultPrimaryText,
                          height: 1.2,
                          letterSpacing: -0.31,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    DateFormat('EEEE, dd MMMM yyyy').format(date),
                    style: AppTextStyles.regular().white
                        .s(12)
                        .copyWith(
                          color: AppColors.defaultPrimaryText.withAlpha(204),
                          height: 1.3,
                          letterSpacing: 0,
                        ),
                  ),
                ],
              ),
            ),
            if (hasActivity)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.completeRecordColor,
                size: 22,
              ),
            IconButton(
              onPressed: onClose,
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.defaultPrimaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityContent extends StatelessWidget {
  const _ActivityContent({required this.day, required this.activities});

  final RunDayStat day;
  final List<RunActivity> activities;

  @override
  Widget build(BuildContext context) {
    final distance = MeasurementFormatter.distance(day.distanceKilometers);
    final count = day.activityCount == 0
        ? activities.length
        : day.activityCount;
    final metrics = [
      _DetailMetricData(
        icon: Icons.route_rounded,
        label: 'runScreen.distance'.tr(),
        value: distance.label,
      ),
      _DetailMetricData(
        icon: Icons.timer_outlined,
        label: 'runScreen.totalTime'.tr(),
        value: MeasurementFormatter.duration(day.duration),
      ),
      _DetailMetricData(
        icon: Icons.local_fire_department_outlined,
        label: 'runScreen.calories'.tr(),
        value: '${day.calories} cal',
      ),
      _DetailMetricData(
        icon: Icons.speed_rounded,
        label: 'runScreen.averagePace'.tr(),
        value: '${MeasurementFormatter.pace(day.pacePerKilometer)} /km',
      ),
      _DetailMetricData(
        icon: Icons.directions_walk_rounded,
        label: 'runScreen.steps'.tr(),
        value: NumberFormat.decimalPattern().format(day.steps),
      ),
      _DetailMetricData(
        icon: Icons.flag_outlined,
        label: 'runScreen.sessions'.tr(),
        value: count.toString(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.85,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          padding: EdgeInsets.only(top: 16, bottom: 0),
          itemCount: metrics.length,
          itemBuilder: (context, index) => _DetailMetric(data: metrics[index]),
        ),
        if (activities.isNotEmpty) ...[
          Gap(16),
          Text(
            'runScreen.recordedSessions'.tr(),
            style: AppTextStyles.semiBold()
                .s(16)
                .copyWith(
                  color: AppColors.primaryText(context),
                  height: 1.2,
                  letterSpacing: -0.15,
                ),
          ),
          const SizedBox(height: 10),
          ...activities.map(_SessionRecord.new),
        ],
      ],
    );
  }
}

class _DetailMetricData {
  const _DetailMetricData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({required this.data});

  final _DetailMetricData data;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryButtonColor.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primaryButtonColor.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Icon(
                  data.icon,
                  size: 18,
                  color: AppColors.primaryButtonColor,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.regular()
                        .s(9)
                        .copyWith(
                          color: AppColors.secondaryText(context),
                          height: 1,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    data.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.semiBold()
                        .s(14)
                        .copyWith(
                          color: AppColors.primaryText(context),
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

class _SessionRecord extends StatelessWidget {
  const _SessionRecord(this.activity);

  final RunActivity activity;

  @override
  Widget build(BuildContext context) {
    final distance = MeasurementFormatter.distance(activity.distanceKilometers);
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.topHeaderBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.directions_run_rounded,
                color: AppColors.completeRecordColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('hh:mm a').format(activity.startedAt),
                      style: AppTextStyles.semiBold().white
                          .s(12)
                          .copyWith(
                            color: AppColors.defaultPrimaryText,
                            height: 1,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${distance.label} • '
                      '${MeasurementFormatter.duration(activity.duration)} • '
                      '${activity.steps} steps • ${activity.calories} cal',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.regular().white
                          .s(10)
                          .copyWith(
                            color: AppColors.defaultPrimaryText.withAlpha(190),
                            height: 1.2,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyActivityContent extends StatelessWidget {
  const _EmptyActivityContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          const Icon(
            Icons.directions_run_rounded,
            size: 52,
            color: AppColors.inactiveIconColor,
          ),
          const SizedBox(height: 14),
          Text(
            'runScreen.noActivityDetails'.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.regular()
                .s(14)
                .copyWith(color: AppColors.secondaryText(context), height: 1.4),
          ),
        ],
      ),
    );
  }
}
