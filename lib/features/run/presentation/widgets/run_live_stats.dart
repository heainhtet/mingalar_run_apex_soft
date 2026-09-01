import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/measurement_formatter.dart';
import '../../../../core/utils/text_extensions.dart';
import '../models/run_session_state.dart';

class RunLiveStats extends StatelessWidget {
  const RunLiveStats({super.key, required this.state});

  final RunSessionState state;

  @override
  Widget build(BuildContext context) {
    final pace = state.pacePerKilometer;
    final paceText = pace == null ? '0:00' : _formatPace(pace);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _LiveStat(
            label: 'runScreen.distance'.tr(),
            value: MeasurementFormatter.distance(
              state.distanceKilometers,
            ).label,
          ),
        ),
        Expanded(child: _AnimatedStepStat(steps: state.steps)),
        Expanded(
          child: _LiveStat(
            label: 'runScreen.pace'.tr(),
            value: '$paceText /km',
          ),
        ),
        Expanded(
          child: _LiveStat(
            label: 'runScreen.calories'.tr(),
            value: '${state.calories} cal',
          ),
        ),
      ],
    );
  }

  String _formatPace(Duration pace) {
    final seconds = pace.inSeconds.remainder(Duration.secondsPerMinute);
    return '${pace.inMinutes}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _AnimatedStepStat extends StatelessWidget {
  const _AnimatedStepStat({required this.steps});

  final int steps;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: steps.toDouble()),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return _LiveStat(
          label: 'runScreen.steps'.tr(),
          value: value.round().toString(),
        );
      },
    );
  }
}

class _LiveStat extends StatelessWidget {
  const _LiveStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.regular()
              .s(10)
              .copyWith(color: AppColors.secondaryText(context), height: 1),
        ),
        const Gap(4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.semiBold()
              .s(14)
              .copyWith(color: AppColors.primaryText(context), height: 1),
        ),
      ],
    );
  }
}
