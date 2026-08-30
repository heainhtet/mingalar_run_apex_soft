import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/widgets/animated_list_entry.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';
import '../providers/run_providers.dart';
import '../widgets/explore_runs_header.dart';
import '../widgets/run_calendar_dialog.dart';
import '../widgets/run_calendar_section.dart';
import '../widgets/run_timer_card.dart';
import '../widgets/runs_week_section.dart';

@RoutePage()
class RunPage extends ConsumerWidget {
  const RunPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarDays = ref.watch(runCalendarDaysProvider);
    final activities = ref.watch(runActivitiesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.runGradientStart, AppColors.runGradientEnd],
          ),
        ),
        child: Column(
          children: [
            const AnimatedListEntry(index: 0, child: ExploreRunsHeader()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                physics: const BouncingScrollPhysics(),
                children: [
                  AnimatedListEntry(
                    index: 1,
                    child: Text(
                      'runScreen.personalRun'.tr(),
                      style: AppTextStyles.medium().white
                          .s(22)
                          .copyWith(
                            color: AppColors.defaultPrimaryText,
                            height: 1,
                            letterSpacing: -0.31,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedListEntry(
                    index: 2,
                    child: RunTimerCard(onStartRunning: () {}),
                  ),
                  const SizedBox(height: 24),
                  AnimatedListEntry(
                    index: 3,
                    child: RunCalendarSection(
                      days: calendarDays,
                      onSeeAll: () => showRunCalendarDialog(
                        context,
                        completedDates: activities.map(
                          (activity) => activity.startedAt,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedListEntry(
                    index: 4,
                    child: RunsWeekSection(activities: activities),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
