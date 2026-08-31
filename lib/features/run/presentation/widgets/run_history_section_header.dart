import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';

class RunHistorySectionHeader extends StatelessWidget {
  const RunHistorySectionHeader({
    super.key,
    required this.title,
    required this.onShowAll,
  });

  final String title;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.semiBold().white
                .s(18)
                .copyWith(
                  color: AppColors.defaultPrimaryText,
                  height: 16 / 18,
                  letterSpacing: 0,
                ),
          ),
        ),
        TextButton(
          onPressed: onShowAll,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.defaultPrimaryText,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: Text(
            'runScreen.showAll'.tr(),
            style: AppTextStyles.medium().white
                .s(11)
                .copyWith(
                  color: AppColors.defaultPrimaryText,
                  height: 1,
                  letterSpacing: 0,
                ),
          ),
        ),
      ],
    );
  }
}
