import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/text_extensions.dart';

class AppBrandHeader extends StatelessWidget {
  const AppBrandHeader({super.key, this.trailing}) : compact = false;

  const AppBrandHeader.compact({super.key, this.trailing}) : compact = true;

  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  'onboarding.appName'.tr(),
                  maxLines: 1,
                  style: AppTextStyles.semiBold().white
                      .s(36)
                      .copyWith(
                        color: AppColors.defaultPrimaryText,
                        fontStyle: FontStyle.italic,
                        height: 1,
                        letterSpacing: 0,
                      ),
                ),
              ),

              Gap(6),
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
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 16), trailing!],
      ],
    );
  }
}
