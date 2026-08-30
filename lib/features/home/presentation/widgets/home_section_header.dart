import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.actionLabel,
    this.onActionPressed,
    this.titleColor,
    this.actionColor,
  });

  final String title;
  final String actionLabel;
  final VoidCallback? onActionPressed;
  final Color? titleColor;
  final Color? actionColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.medium().black
                .s(16)
                .copyWith(
                  color: titleColor ?? AppColors.defaultBlackText,
                  height: 1,
                  letterSpacing: 0,
                ),
          ),
        ),
        InkWell(
          onTap: onActionPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              actionLabel,
              textAlign: TextAlign.right,
              style: AppTextStyles.medium()
                  .s(10)
                  .copyWith(
                    color: actionColor ?? AppColors.featureViewAllText,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
