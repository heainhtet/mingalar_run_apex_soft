import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/widgets/animated_list_entry.dart';
import '../../../../core/routers/app_router.gr.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';
import '../providers/run_providers.dart';
import '../widgets/explore_runs_header.dart';
import '../widgets/run_calendar_dialog.dart';
import '../widgets/run_calendar_section.dart';
import '../widgets/run_mode_card.dart';
import '../widgets/run_timer_card.dart';
import '../widgets/runs_week_section.dart';

@RoutePage()
class RunPage extends ConsumerWidget {
  const RunPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMode = ref.watch(selectedRunTabProvider);
    final calendarDays = ref.watch(runCalendarDaysProvider);
    final lastSevenDays = ref.watch(runLastSevenDaysProvider);

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
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        _runModeLabelKeys[selectedMode].tr(),
                        key: ValueKey(selectedMode),
                        style: AppTextStyles.medium().white
                            .s(22)
                            .copyWith(
                              color: AppColors.defaultPrimaryText,
                              height: 1,
                              letterSpacing: -0.31,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: selectedMode == 0
                        ? const SizedBox.shrink(key: ValueKey('personal-mode'))
                        : Padding(
                            key: ValueKey(selectedMode),
                            padding: const EdgeInsets.only(bottom: 16),
                            child: RunModeCard(modeIndex: selectedMode),
                          ),
                  ),
                  const AnimatedListEntry(index: 2, child: RunTimerCard()),
                  const SizedBox(height: 24),
                  AnimatedListEntry(
                    index: 3,
                    child: RunCalendarSection(
                      days: calendarDays,
                      onSeeAll: () => showRunCalendarDialog(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedListEntry(
                    index: 4,
                    child: RunsWeekSection(
                      days: lastSevenDays,
                      onShowAll: () =>
                          context.router.push(const RunHistoryRoute()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _runModeLabelKeys = [
    'runScreen.personalRun',
    'runScreen.funRun',
    'runScreen.challengeRun',
  ];
}
