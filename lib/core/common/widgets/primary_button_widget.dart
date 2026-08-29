import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/text_extensions.dart';

enum PrimaryButtonVariant { filled, outlined }

class PrimaryButtonWidget extends StatelessWidget {
  const PrimaryButtonWidget({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.onPressed,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = false,
    this.fontSize,
    this.variant = PrimaryButtonVariant.filled,
    this.borderColor,
    this.borderWidth = 2,
    this.textStyle,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final double borderWidth;
  final double? fontSize;
  final bool isLoading;
  final PrimaryButtonVariant variant;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final isOutlined = variant == PrimaryButtonVariant.outlined;
    final resolvedTextColor =
        textColor ??
        (isOutlined ? AppColors.tabIndicatorColor : AppColors.white);
    final resolvedBackgroundColor = isOutlined
        ? Colors.transparent
        : backgroundColor ?? AppColors.primaryButtonColor;
    final resolvedRadius = BorderRadius.circular(borderRadius ?? 8);

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: resolvedBackgroundColor,
          foregroundColor: resolvedTextColor,
          disabledBackgroundColor: resolvedBackgroundColor.withValues(
            alpha: 0.65,
          ),
          disabledForegroundColor: resolvedTextColor,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: resolvedRadius,
            side: isOutlined
                ? BorderSide(
                    color: borderColor ?? AppColors.tabIndicatorColor,
                    width: borderWidth,
                  )
                : BorderSide.none,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: isLoading
              ? SizedBox.square(
                  key: const ValueKey('primary-button-loader'),
                  dimension: 20,
                  child: CircularProgressIndicator(
                    color: resolvedTextColor,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  text,
                  key: const ValueKey('primary-button-label'),
                  textAlign: TextAlign.center,
                  style:
                      textStyle ??
                      AppTextStyles.semiBold()
                          .s(fontSize ?? 16)
                          .copyWith(
                            color: resolvedTextColor,
                            height: 1,
                            letterSpacing: 0,
                          ),
                ),
        ),
      ),
    );
  }
}
