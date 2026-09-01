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
import 'run_calendar_dialog.dart';
import 'run_calendar_section.dart';
import 'run_timer_card.dart';
import 'runs_week_section.dart';

/// Shared tracking sections used by each run-mode tab.
///
/// A mode can add its own introduction without duplicating the active run,
/// calendar, or history integrations.
class RunTabContent extends ConsumerWidget {
  const RunTabContent({super.key, required this.titleKey, this.introduction});

  final String titleKey;
  final Widget? introduction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarDays = ref.watch(runCalendarDaysProvider);
    final lastSevenDays = ref.watch(runLastSevenDaysProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedListEntry(
          index: 1,
          child: Text(
            titleKey.tr(),
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
        if (introduction case final introduction?) ...[
          AnimatedListEntry(index: 2, child: introduction),
          const SizedBox(height: 16),
        ],
        const AnimatedListEntry(index: 3, child: RunTimerCard()),
        const SizedBox(height: 24),
        AnimatedListEntry(
          index: 4,
          child: RunCalendarSection(
            days: calendarDays,
            onSeeAll: () => showRunCalendarDialog(context),
          ),
        ),
        const SizedBox(height: 24),
        AnimatedListEntry(
          index: 5,
          child: RunsWeekSection(
            days: lastSevenDays,
            onShowAll: () => context.router.push(const RunHistoryRoute()),
          ),
        ),
      ],
    );
  }
}
