import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/common/widgets/primary_button_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';

class OnboardingActionButtons extends StatelessWidget {
  const OnboardingActionButtons({
    super.key,
    required this.onGetStarted,
    required this.onSignIn,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final buttonTextStyle = AppTextStyles.semiBold()
        .s(16)
        .copyWith(height: 1, letterSpacing: 0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PrimaryButtonWidget(
          text: 'onboarding.getStarted'.tr(),
          onPressed: onGetStarted,
          height: 54,
          borderRadius: 28,
          backgroundColor: AppColors.tabIndicatorColor,
          textColor: AppColors.defaultPrimaryText,
          textStyle: buttonTextStyle.copyWith(
            color: AppColors.defaultPrimaryText,
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButtonWidget(
          text: 'onboarding.alreadyHaveAccount'.tr(),
          onPressed: onSignIn,
          height: 54,
          borderRadius: 28,
          variant: PrimaryButtonVariant.outlined,
          borderColor: AppColors.tabIndicatorColor,
          textColor: AppColors.tabIndicatorColor,
          textStyle: buttonTextStyle.copyWith(
            color: AppColors.tabIndicatorColor,
          ),
        ),
      ],
    );
  }
}
