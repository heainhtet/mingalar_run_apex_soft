import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/common/widgets/app_flushbar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../run/domain/entities/run_day_stat.dart';
import '../../../run/presentation/services/run_share_service.dart';
import '../../../run/presentation/widgets/run_activity_detail_dialog.dart';
import '../../../run/presentation/widgets/run_day_tile.dart';
import '../../../run/presentation/widgets/run_history_section_header.dart';

class ProfileRunHistorySection extends StatelessWidget {
  const ProfileRunHistorySection({
    super.key,
    required this.days,
    required this.onShowAll,
  });

  final List<RunDayStat> days;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RunHistorySectionHeader(
          title: 'profileScreen.runHistory'.tr(),
          onShowAll: onShowAll,
        ),
        const Gap(20),
        ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days.length,
          separatorBuilder: (context, index) => const Gap(12),
          itemBuilder: (context, index) {
            final day = days[index];
            return RunDayTile(
              day: day,
              color: AppColors.profileTileColor,
              showShareAction: true,
              shareLabel: 'profileScreen.share'.tr(),
              onShare: day.hasActivity
                  ? (origin) => _shareDay(context, day, origin)
                  : null,
              onTap: () => showRunActivityDetailDialog(context, day: day),
            );
          },
        ),
      ],
    );
  }

  Future<void> _shareDay(
    BuildContext context,
    RunDayStat day,
    Rect? shareOrigin,
  ) async {
    try {
      await RunShareService.shareDay(day, shareOrigin);
    } catch (_) {
      if (context.mounted) {
        AppFlushbar.error(context, 'profileScreen.shareFailed'.tr());
      }
    }
  }
}
