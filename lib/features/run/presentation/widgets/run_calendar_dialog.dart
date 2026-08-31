import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'run_calendar_dialog_view.dart';

export 'run_calendar_dialog_view.dart' show RunCalendarDialog;

Future<void> showRunCalendarDialog(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppColors.black.withAlpha(153),
    transitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const RunCalendarDialog();
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
          scale: Tween<double>(begin: 0.88, end: 1).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}
