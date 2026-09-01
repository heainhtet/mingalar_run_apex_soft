import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/common/widgets/animated_list_entry.dart';
import '../../../../core/common/widgets/discovery_card.dart';
import '../../../../core/common/widgets/discovery_page_header.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/challenges_provider.dart';

@RoutePage()
class FeaturedChallengesPage extends ConsumerWidget {
  const FeaturedChallengesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(featuredChallengesProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBackground(context),
      body: Column(
        children: [
          DiscoveryPageHeader(
            title: 'challenges.title'.tr(),
            subtitle: 'challenges.subtitle'.tr(),
            icon: Icons.emoji_events_outlined,
            showBackButton: true,
          ),
          Gap(20),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  sliver: SliverList.separated(
                    itemCount: challenges.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      final challenge = challenges[index];

                      return AnimatedListEntry(
                        index: index,
                        child: DiscoveryCard(
                          assetPath: challenge.assetPath,
                          title: challenge.titleKey.tr(),
                          subtitle: challenge.descriptionKey.tr(),
                          badge: challenge.badgeKey.tr(),
                          metadata: [
                            DiscoveryMetadata(
                              icon: Icons.route_rounded,
                              label: challenge.distance,
                            ),
                            DiscoveryMetadata(
                              icon: Icons.calendar_today_outlined,
                              label: challenge.duration,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
