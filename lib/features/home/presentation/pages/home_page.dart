import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/widgets/animated_list_entry.dart';
import '../../../../core/common/widgets/app_brand_header.dart';
import '../../../../core/routers/app_router.gr.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../wrapper/presentation/providers/wrapper_provider.dart';
import '../providers/home_providers.dart';
import '../providers/home_notification_providers.dart';
import '../widgets/current_week_strip.dart';
import '../widgets/home_event_section.dart';
import '../widgets/home_featured_challenges_section.dart';
import '../widgets/home_notification_button.dart';
import '../widgets/start_run_card.dart';

@RoutePage()
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDate = ref.watch(currentDateProvider);
    final notificationCount = ref.watch(homeNotificationsProvider).length;
    final headerTop = math.max(39.0, MediaQuery.paddingOf(context).top + 12);

    return Scaffold(
      backgroundColor: AppColors.pageBackground(context),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: ClipRRect(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(130)),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppColors.homeGradient(context),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                children: [
                  AnimatedListEntry(
                    index: 0,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, headerTop, 20, 0),
                      child: AppBrandHeader.compact(
                        trailing: HomeNotificationButton(
                          count: notificationCount,
                          onPressed: () =>
                              context.router.push(const NotificationsRoute()),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  AnimatedListEntry(
                    index: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: CurrentWeekStrip(currentDate: currentDate),
                    ),
                  ),

                  const SizedBox(height: 22),

                  AnimatedListEntry(
                    index: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 8,
                      ),
                      child: StartRunCard(
                        onStartRunning: () =>
                            ref.read(wrapperProvider.notifier).changeIndex(1),
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(top: 16, bottom: 120),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        AnimatedListEntry(
                          index: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: HomeFeaturedChallengesSection(
                              onShowMore: () => context.router.push(
                                const FeaturedChallengesRoute(),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        AnimatedListEntry(
                          index: 4,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: HomeEventSection(
                              onShowMore: () => ref
                                  .read(wrapperProvider.notifier)
                                  .changeIndex(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
