import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';
import '../models/run_calendar_models.dart';
import 'run_activity_tile.dart';

class RunsWeekSection extends StatelessWidget {
  const RunsWeekSection({super.key, required this.activities});

  final List<RunActivity> activities;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'runScreen.thisWeek'.tr(),
          style: AppTextStyles.semiBold().white
              .s(18)
              .copyWith(
                color: AppColors.defaultPrimaryText,
                height: 16 / 18,
                letterSpacing: 0,
              ),
        ),
        const SizedBox(height: 12),
        ...activities.expand(
          (activity) => [
            RunActivityTile(activity: activity),
            const SizedBox(height: 12),
          ],
        ),
      ],
    );
  }
}
