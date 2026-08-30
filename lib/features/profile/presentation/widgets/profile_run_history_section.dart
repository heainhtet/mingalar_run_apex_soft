import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../run/presentation/models/run_calendar_models.dart';
import '../../../run/presentation/widgets/run_activity_tile.dart';
import 'profile_section_title.dart';

class ProfileRunHistorySection extends StatelessWidget {
  const ProfileRunHistorySection({super.key, required this.activities});

  final List<RunActivity> activities;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionTitle('profileScreen.runHistory'.tr()),
        const Gap(20),
        ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          separatorBuilder: (context, index) => const Gap(12),
          itemBuilder: (context, index) {
            final activity = activities[index];
            return RunActivityTile(
              activity: activity,
              color: AppColors.profileTileColor,
              showShareAction: true,
              shareLabel: 'profileScreen.share'.tr(),
              onShare: () => _shareActivity(context, activity),
            );
          },
        ),
      ],
    );
  }

  Future<void> _shareActivity(
    BuildContext context,
    RunActivity activity,
  ) async {
    final paceSeconds = activity.pacePerKilometer.inSeconds.remainder(60);
    final pace =
        '${activity.pacePerKilometer.inMinutes}:${paceSeconds.toString().padLeft(2, '0')}';
    final renderBox = context.findRenderObject() as RenderBox?;

    await SharePlus.instance.share(
      ShareParams(
        title: 'Mingalar Run',
        subject: 'profileScreen.sharedRunSubject'.tr(),
        text:
            '${'profileScreen.sharedRunTitle'.tr()}\n'
            '${DateFormat('dd MMM yyyy, hh:mm a').format(activity.startedAt)}\n'
            '${activity.distanceKilometers.toStringAsFixed(1)} km • '
            '${activity.duration.inMinutes} min • '
            '${activity.calories} cal • $pace min/km',
        sharePositionOrigin: renderBox == null
            ? null
            : renderBox.localToGlobal(Offset.zero) & renderBox.size,
      ),
    );
  }
}
