import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/run_calendar_models.dart';
import '../providers/run_providers.dart';
import 'run_calendar_dialog_header.dart';
import 'run_calendar_legend.dart';
import 'run_calendar_month_grid.dart';
import 'run_calendar_month_overview.dart';

class RunCalendarDialog extends ConsumerWidget {
  const RunCalendarDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(runCurrentMonthCalendarDaysProvider);
    final currentDate = ref.watch(runCurrentDateProvider);
    final localizations = MaterialLocalizations.of(context);
    final leadingDays =
        DateTime(currentDate.year, currentDate.month).weekday %
        DateTime.daysPerWeek;
    final completedDays = days
        .where((day) => day.status == RunCalendarStatus.completeRecord)
        .length;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.sizeOf(context).height * 0.84,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: ColoredBox(
            color: AppColors.surface(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RunCalendarDialogHeader(
                  monthLabel: localizations.formatMonthYear(currentDate),
                  onClose: () => Navigator.of(context).pop(),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RunCalendarMonthOverview(
                          completedDays: completedDays,
                          totalDays: days.length,
                        ),
                        const SizedBox(height: 12),
                        RunCalendarMonthGrid(
                          days: days,
                          leadingDays: leadingDays,
                          localizations: localizations,
                        ),
                        const SizedBox(height: 18),
                        const RunCalendarLegend(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
