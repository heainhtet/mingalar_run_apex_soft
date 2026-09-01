import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';

class ProfileSettingsHeader extends StatelessWidget {
  const ProfileSettingsHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.runGradient(context),
        ),
      ),
      child: SafeArea(
        bottom: false,

        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 14, 20, 18),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.defaultPrimaryText,
                ),
              ),
              const Gap(8),
              Text(
                'profileScreen.settings'.tr(),
                style: AppTextStyles.semiBold().white
                    .s(22)
                    .copyWith(
                      color: AppColors.defaultPrimaryText,
                      letterSpacing: -0.5,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
