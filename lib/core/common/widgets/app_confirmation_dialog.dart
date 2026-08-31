import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/text_extensions.dart';
import 'primary_button_widget.dart';

Future<bool> showAppConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
  required IconData icon,
  Color confirmColor = AppColors.caloriesIconColor,
}) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppColors.black.withAlpha(153),
    transitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _AppConfirmationDialog(
        title: title,
        message: message,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        icon: icon,
        confirmColor: confirmColor,
      );
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
  return result ?? false;
}

class _AppConfirmationDialog extends StatelessWidget {
  const _AppConfirmationDialog({
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.icon,
    required this.confirmColor,
  });

  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final IconData icon;
  final Color confirmColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: ColoredBox(
            color: AppColors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ConfirmationHeader(title: title, icon: icon),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                  child: Column(
                    children: [
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.regular()
                            .s(14)
                            .copyWith(
                              color: AppColors.cardDescriptionText,
                              height: 1.5,
                              letterSpacing: -0.1,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButtonWidget(
                              text: cancelLabel,
                              onPressed: () => Navigator.of(context).pop(false),
                              variant: PrimaryButtonVariant.outlined,
                              borderColor: AppColors.primaryButtonColor,
                              textColor: AppColors.primaryButtonColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PrimaryButtonWidget(
                              text: confirmLabel,
                              onPressed: () => Navigator.of(context).pop(true),
                              backgroundColor: confirmColor,
                              textColor: AppColors.defaultPrimaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _ConfirmationHeader extends StatelessWidget {
  const _ConfirmationHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.runGradientStart, AppColors.runGradientEnd],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 10, 18),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.white.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  icon,
                  color: AppColors.defaultPrimaryText,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.semiBold().white
                    .s(20)
                    .copyWith(
                      color: AppColors.defaultPrimaryText,
                      height: 1.2,
                      letterSpacing: -0.31,
                    ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(false),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.defaultPrimaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
