import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';
import '../models/run_calendar_models.dart';
import '../providers/run_providers.dart';
import 'run_calendar_legend.dart';

Future<void> showRunCalendarDialog(
  BuildContext context, {
  required Iterable<DateTime> completedDates,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (context, animation, secondaryAnimation) {
      return RunCalendarDialog(completedDates: completedDates);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

class RunCalendarDialog extends ConsumerWidget {
  const RunCalendarDialog({super.key, required this.completedDates});

  final Iterable<DateTime> completedDates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleMonth = ref.watch(runCalendarVisibleMonthProvider);
    final today = ref.watch(runCurrentDateProvider);
    final localizations = MaterialLocalizations.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColoredBox(
                  color: AppColors.topHeaderBackground,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 10, 10),
                    child: _DialogHeader(
                      onClose: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                ColoredBox(
                  color: AppColors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                    child: Column(
                      children: [
                        _MonthNavigator(
                          label: localizations.formatMonthYear(visibleMonth),
                          onPrevious: () => _changeMonth(ref, visibleMonth, -1),
                          onNext: () => _changeMonth(ref, visibleMonth, 1),
                        ),
                        const SizedBox(height: 12),
                        _WeekdayHeader(localizations: localizations),
                        const SizedBox(height: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(
                                  begin: 0.98,
                                  end: 1,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _MonthGrid(
                            key: ValueKey(
                              '${visibleMonth.year}-${visibleMonth.month}',
                            ),
                            month: visibleMonth,
                            today: today,
                            completedDates: completedDates,
                            firstDayOfWeekIndex:
                                localizations.firstDayOfWeekIndex,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const ColoredBox(
                  color: AppColors.topHeaderBackground,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(18, 12, 18, 14),
                    child: RunCalendarLegend(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _changeMonth(WidgetRef ref, DateTime month, int offset) {
    ref.read(runCalendarVisibleMonthProvider.notifier).state = DateTime(
      month.year,
      month.month + offset,
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'runScreen.calendar'.tr(),
            style: AppTextStyles.semiBold().white
                .s(18)
                .copyWith(
                  color: AppColors.defaultPrimaryText,
                  height: 1.2,
                  letterSpacing: 0,
                ),
          ),
        ),
        IconButton(
          onPressed: onClose,
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.close_rounded, color: AppColors.white),
        ),
      ],
    );
  }
}

class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          tooltip: localizations.previousMonthTooltip,
          visualDensity: VisualDensity.compact,
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: AppColors.tabIndicatorColor,
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Text(
              label,
              key: ValueKey(label),
              textAlign: TextAlign.center,
              style: AppTextStyles.medium()
                  .s(15)
                  .copyWith(
                    color: AppColors.cardLabelText,
                    height: 1,
                    letterSpacing: 0,
                  ),
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          tooltip: localizations.nextMonthTooltip,
          visualDensity: VisualDensity.compact,
          icon: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.tabIndicatorColor,
          ),
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({required this.localizations});

  final MaterialLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final labels = List.generate(DateTime.daysPerWeek, (index) {
      final weekdayIndex =
          (localizations.firstDayOfWeekIndex + index) % DateTime.daysPerWeek;
      return localizations.narrowWeekdays[weekdayIndex];
    });

    return Row(
      children: labels
          .map(
            (label) => Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.medium().white
                    .s(10)
                    .copyWith(
                      color: AppColors.cardDescriptionText,
                      height: 1,
                      letterSpacing: 0,
                    ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    super.key,
    required this.month,
    required this.today,
    required this.completedDates,
    required this.firstDayOfWeekIndex,
  });

  final DateTime month;
  final DateTime today;
  final Iterable<DateTime> completedDates;
  final int firstDayOfWeekIndex;

  @override
  Widget build(BuildContext context) {
    final firstDate = DateTime(month.year, month.month);
    final firstDateSundayIndex = firstDate.weekday % DateTime.daysPerWeek;
    final leadingDays =
        (firstDateSundayIndex - firstDayOfWeekIndex + DateTime.daysPerWeek) %
        DateTime.daysPerWeek;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: DateTime.daysPerWeek,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: leadingDays + daysInMonth,
      itemBuilder: (context, index) {
        if (index < leadingDays) return const SizedBox.shrink();

        final date = DateTime(month.year, month.month, index - leadingDays + 1);
        final status = isSameCalendarDate(date, today)
            ? RunCalendarStatus.today
            : completedDates.any(
                (completed) => isSameCalendarDate(completed, date),
              )
            ? RunCalendarStatus.completeRecord
            : RunCalendarStatus.noRecord;

        return _DialogCalendarDay(date: date, status: status);
      },
    );
  }
}

class _DialogCalendarDay extends StatelessWidget {
  const _DialogCalendarDay({required this.date, required this.status});

  final DateTime date;
  final RunCalendarStatus status;

  @override
  Widget build(BuildContext context) {
    final statusBorderColor = switch (status) {
      RunCalendarStatus.completeRecord => AppColors.completeRecordColor,
      RunCalendarStatus.today => AppColors.tabIndicatorColor,
      RunCalendarStatus.noRecord => AppColors.inactiveIconColor,
    };
    final isToday = status == RunCalendarStatus.today;

    return Center(
      child: Semantics(
        label: '${date.day}',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isToday ? AppColors.tabIndicatorColor : Colors.transparent,
            border: Border.all(color: statusBorderColor, width: 2),
          ),
          child: Text(
            '${date.day}',
            style: AppTextStyles.medium()
                .s(11)
                .copyWith(
                  color: isToday
                      ? AppColors.defaultPrimaryText
                      : AppColors.cardLabelText,
                  height: 1,
                  letterSpacing: 0,
                ),
          ),
        ),
      ),
    );
  }
}
