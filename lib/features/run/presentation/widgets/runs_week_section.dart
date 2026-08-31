import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/run_day_stat.dart';
import 'run_activity_detail_dialog.dart';
import 'run_day_tile.dart';
import 'run_history_section_header.dart';

class RunsWeekSection extends StatelessWidget {
  const RunsWeekSection({
    super.key,
    required this.days,
    required this.onShowAll,
  });

  final List<RunDayStat> days;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RunHistorySectionHeader(
          title: 'runScreen.thisWeek'.tr(),
          onShowAll: onShowAll,
        ),
        const SizedBox(height: 12),
        ...days.expand(
          (day) => [
            RunDayTile(
              day: day,
              onTap: () => showRunActivityDetailDialog(context, day: day),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ],
    );
  }
}
