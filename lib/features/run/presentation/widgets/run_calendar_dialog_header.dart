import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';

class RunCalendarDialogHeader extends StatelessWidget {
  const RunCalendarDialogHeader({
    super.key,
    required this.monthLabel,
    required this.onClose,
  });

  final String monthLabel;
  final VoidCallback onClose;

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
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.defaultPrimaryText,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'runScreen.calendar'.tr(),
                    style: AppTextStyles.semiBold().white
                        .s(20)
                        .copyWith(
                          color: AppColors.defaultPrimaryText,
                          height: 1.2,
                          letterSpacing: -0.31,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    monthLabel,
                    style: AppTextStyles.regular().white
                        .s(12)
                        .copyWith(
                          color: AppColors.defaultPrimaryText.withAlpha(204),
                          height: 1.3,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onClose,
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
