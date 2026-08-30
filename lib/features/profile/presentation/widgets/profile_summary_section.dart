import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../models/profile_models.dart';
import 'profile_section_title.dart';
import 'profile_summary_card.dart';

class ProfileSummarySection extends StatelessWidget {
  const ProfileSummarySection({super.key, required this.metrics});

  final List<ProfileSummaryMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionTitle('profileScreen.runSummary'.tr()),
        const Gap(24),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            mainAxisExtent: 101,
          ),
          itemBuilder: (context, index) {
            return ProfileSummaryCard(metric: metrics[index]);
          },
        ),
      ],
    );
  }
}
