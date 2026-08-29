import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/assets_constant.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';
import 'onboarding_action_buttons.dart';

class OnboardingContentCard extends StatelessWidget {
  const OnboardingContentCard({
    super.key,
    required this.onGetStarted,
    required this.onSignIn,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 570;
          final horizontalPadding = constraints.maxWidth < 360 ? 24.0 : 36.0;
          final artworkHeight = math.min(
            compact ? 132.0 : 190.0,
            constraints.maxHeight * (compact ? 0.25 : 0.29),
          );

          return Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              compact ? 18 : 32,
              horizontalPadding,
              MediaQuery.paddingOf(context).bottom + (compact ? 18 : 28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    AssetsConstant.onboardingRunner,
                    height: artworkHeight,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                SizedBox(height: compact ? 14 : 28),
                Text(
                  'onboarding.title'.tr(),
                  style: AppTextStyles.semiBold()
                      .s(30)
                      .copyWith(
                        color: AppColors.onBoardingWelcomeText,
                        height: 1,
                        letterSpacing: 0,
                      ),
                ),
                SizedBox(height: compact ? 12 : 20),
                Text(
                  'onboarding.description'.tr(),
                  style: AppTextStyles.regular().black
                      .s(14)
                      .copyWith(
                        color: AppColors.defaultBlackText,
                        height: 1,
                        letterSpacing: 0,
                      ),
                ),
                const Spacer(),
                OnboardingActionButtons(
                  onGetStarted: onGetStarted,
                  onSignIn: onSignIn,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
