import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'onboarding.appName'.tr(),
          style: AppTextStyles.semiBold().white
              .s(36)
              .copyWith(
                color: AppColors.defaultPrimaryText,
                fontStyle: FontStyle.italic,
                height: 1,
                letterSpacing: 0,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'onboarding.clubName'.tr(),
          style: AppTextStyles.regular().white
              .s(20)
              .copyWith(
                color: AppColors.defaultPrimaryText,
                height: 1,
                letterSpacing: 0,
              ),
        ),
      ],
    );
  }
}
