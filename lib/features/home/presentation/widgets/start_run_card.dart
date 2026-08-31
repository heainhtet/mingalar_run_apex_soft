import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../../../core/common/widgets/primary_button_widget.dart';
import '../../../../core/constants/assets_constant.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/measurement_formatter.dart';
import '../../../../core/utils/text_extensions.dart';
import '../../../run/domain/entities/run_activity.dart';
import '../../../run/presentation/providers/run_providers.dart';
import '../../../run/presentation/providers/run_session_provider.dart';

class StartRunCard extends ConsumerWidget {
  const StartRunCard({super.key, required this.onStartRunning});

  final VoidCallback onStartRunning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(runSessionProvider);
    final activities = ref.watch(runActivitiesProvider);
    final latestRun = activities.value?.firstOrNull;

    return Container(
      height: 196,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x80989898), width: 0.71),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A101828),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0x1A / 255),
            blurRadius: 10,
            spreadRadius: -6,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0x26 / 255),
            blurRadius: 25,
            spreadRadius: -5,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  session.hasStarted
                      ? 'homeScreen.runInProgress'.tr()
                      : latestRun == null
                      ? 'homeScreen.startYourRun'.tr()
                      : 'homeScreen.lastRun'.tr(),
                  style: AppTextStyles.semiBold()
                      .s(18)
                      .copyWith(
                        color: AppColors.cardLabelText,
                        height: 28 / 18,
                        letterSpacing: -0.44,
                      ),
                ),
              ),
              SvgPicture.asset(AssetsConstant.upIcon, width: 24, height: 24),
            ],
          ),
          const Gap(6),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: session.hasStarted
                  ? _ActiveRunSummary(
                      key: const ValueKey('active-run'),
                      elapsed: session.elapsed,
                      stageLabel: session.stage.labelKey.tr(),
                    )
                  : activities.isLoading
                  ? const Center(
                      key: ValueKey('loading-run'),
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryButtonColor,
                        ),
                      ),
                    )
                  : latestRun == null
                  ? const _FirstRunPrompt(key: ValueKey('first-run'))
                  : _LastRunSummary(
                      key: ValueKey(latestRun.id),
                      activity: latestRun,
                    ),
            ),
          ),
          PrimaryButtonWidget(
            text: session.hasStarted
                ? 'homeScreen.openRun'.tr()
                : 'homeScreen.startRunning'.tr(),
            onPressed: onStartRunning,
            height: 52,
            borderRadius: 30,
            backgroundColor: AppColors.primaryButtonColor,
            textColor: AppColors.defaultPrimaryText,
            textStyle: AppTextStyles.semiBold().white
                .s(18)
                .copyWith(
                  color: AppColors.defaultPrimaryText,
                  height: 20 / 18,
                  letterSpacing: 0,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActiveRunSummary extends StatelessWidget {
  const _ActiveRunSummary({
    super.key,
    required this.elapsed,
    required this.stageLabel,
  });

  final Duration elapsed;
  final String stageLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formatElapsed(elapsed),
          style: AppTextStyles.medium()
              .s(30)
              .copyWith(
                color: AppColors.counterTextColor,
                height: 1,
                letterSpacing: 0,
              ),
        ),
        const Gap(12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primaryButtonColor.withAlpha(31),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              stageLabel,
              style: AppTextStyles.medium()
                  .s(11)
                  .copyWith(
                    color: AppColors.cardLabelText,
                    height: 1,
                    letterSpacing: 0,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  static String _formatElapsed(Duration elapsed) {
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes.remainder(60);
    final seconds = elapsed.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}

class _FirstRunPrompt extends StatelessWidget {
  const _FirstRunPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primaryButtonColor.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: const Padding(
            padding: EdgeInsets.all(9),
            child: Icon(
              Icons.directions_run_rounded,
              size: 22,
              color: AppColors.primaryButtonColor,
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: Text(
            'homeScreen.firstRunMessage'.tr(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.regular()
                .s(13)
                .copyWith(
                  color: AppColors.cardDescriptionText,
                  height: 18 / 13,
                  letterSpacing: -0.1,
                ),
          ),
        ),
      ],
    );
  }
}

class _LastRunSummary extends StatelessWidget {
  const _LastRunSummary({super.key, required this.activity});

  final RunActivity activity;

  @override
  Widget build(BuildContext context) {
    final distance = MeasurementFormatter.distance(activity.distanceKilometers);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          DateFormat('dd MMM, hh:mm a').format(activity.startedAt),
          style: AppTextStyles.regular()
              .s(10)
              .copyWith(
                color: AppColors.scoreSumLabelTextColor,
                height: 1,
                letterSpacing: 0,
              ),
        ),
        const Gap(8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _LastRunMetric(icon: Icons.route_rounded, value: distance.label),
            _LastRunMetric(
              icon: Icons.timer_outlined,
              value: MeasurementFormatter.duration(activity.duration),
            ),
            _LastRunMetric(
              icon: Icons.local_fire_department_outlined,
              value: '${activity.calories} cal',
            ),
          ],
        ),
      ],
    );
  }
}

class _LastRunMetric extends StatelessWidget {
  const _LastRunMetric({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primaryButtonColor),
        const Gap(4),
        Text(
          value,
          style: AppTextStyles.medium()
              .s(11)
              .copyWith(
                color: AppColors.cardLabelText,
                height: 1,
                letterSpacing: 0,
              ),
        ),
      ],
    );
  }
}
