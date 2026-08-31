import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/text_extensions.dart';

enum AppFlushbarTone { info, success, error }

abstract final class AppFlushbar {
  static void info(BuildContext context, String message) {
    _show(context, message: message, tone: AppFlushbarTone.info);
  }

  static void success(BuildContext context, String message) {
    _show(context, message: message, tone: AppFlushbarTone.success);
  }

  static void error(BuildContext context, String message) {
    _show(context, message: message, tone: AppFlushbarTone.error);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required AppFlushbarTone tone,
  }) {
    if (!context.mounted) return;
    final presentation = _presentationFor(tone);
    final isInfo = tone == AppFlushbarTone.info;

    unawaited(
      Flushbar<void>(
        messageText: Text(
          message,
          style: AppTextStyles.medium().white
              .s(13)
              .copyWith(
                color: isInfo
                    ? AppColors.cardLabelText
                    : AppColors.defaultPrimaryText,
                height: 1.35,
                letterSpacing: 0,
              ),
        ),
        icon: DecoratedBox(
          decoration: BoxDecoration(
            color: isInfo
                ? AppColors.primaryButtonColor.withAlpha(24)
                : AppColors.white.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              presentation.icon,
              size: 19,
              color: presentation.accent,
            ),
          ),
        ),
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderRadius: BorderRadius.circular(18),
        borderColor: isInfo
            ? AppColors.primaryButtonColor.withAlpha(90)
            : AppColors.white.withAlpha(38),
        borderWidth: 1,
        backgroundGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: presentation.colors,
        ),
        boxShadows: [
          BoxShadow(
            color: AppColors.black.withAlpha(42),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeInCubic,
        animationDuration: const Duration(milliseconds: 420),
        shouldIconPulse: false,
      ).show(context),
    );
  }

  static _FlushbarPresentation _presentationFor(AppFlushbarTone tone) {
    return switch (tone) {
      AppFlushbarTone.info => const _FlushbarPresentation(
        icon: Icons.info_outline_rounded,
        accent: AppColors.primaryButtonColor,
        colors: [AppColors.white, Color(0xFFF2F6FF)],
      ),
      AppFlushbarTone.success => const _FlushbarPresentation(
        icon: Icons.check_rounded,
        accent: AppColors.completeRecordColor,
        colors: [AppColors.primaryButtonColor, AppColors.topHeaderBackground],
      ),
      AppFlushbarTone.error => const _FlushbarPresentation(
        icon: Icons.error_outline_rounded,
        accent: AppColors.defaultPrimaryText,
        colors: [AppColors.caloriesIconColor, AppColors.cardLabelText],
      ),
    };
  }
}

class _FlushbarPresentation {
  const _FlushbarPresentation({
    required this.icon,
    required this.accent,
    required this.colors,
  });

  final IconData icon;
  final Color accent;
  final List<Color> colors;
}
