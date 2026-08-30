import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/text_extensions.dart';

class DiscoveryPageHeader extends StatelessWidget {
  const DiscoveryPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.showBackButton = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.homeGradientStart, AppColors.homeGradientEnd],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(52)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showBackButton)
                IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 40,
                    height: 40,
                  ),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.defaultPrimaryText,
                    size: 20,
                  ),
                )
              else
                const SizedBox(height: 40),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.semiBold().white
                              .s(28)
                              .copyWith(
                                color: AppColors.defaultPrimaryText,
                                height: 1.1,
                                letterSpacing: -0.4,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: AppTextStyles.regular().white
                              .s(14)
                              .copyWith(
                                color: AppColors.defaultPrimaryText.withValues(
                                  alpha: 0.82,
                                ),
                                height: 1.35,
                                letterSpacing: 0,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(
                      dimension: 52,
                      child: Icon(
                        icon,
                        color: AppColors.defaultPrimaryText,
                        size: 27,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
