import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';
import '../models/run_calendar_models.dart';
import 'calendar_indicator.dart';

class RunCalendarLegend extends StatelessWidget {
  const RunCalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.topHeaderBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _LegendSegment(
              status: RunCalendarStatus.completeRecord,
              label: 'runScreen.completeRecord'.tr(),
            ),
            const _LegendDivider(),
            _LegendSegment(
              status: RunCalendarStatus.today,
              label: 'runScreen.today'.tr(),
            ),
            const _LegendDivider(),
            _LegendSegment(
              status: RunCalendarStatus.noRecord,
              label: 'runScreen.noRecord'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendSegment extends StatelessWidget {
  const _LegendSegment({required this.status, required this.label});

  final RunCalendarStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CalendarIndicator(status: status),
            const Gap(8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.regular().white
                    .s(10)
                    .copyWith(
                      color: AppColors.defaultPrimaryText,
                      height: 1,
                      letterSpacing: -0.5,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDivider extends StatelessWidget {
  const _LegendDivider();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.transparent,
      child: const SizedBox(width: 1),
    );
  }
}
