import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/assets_constant.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, this.onSettingsPressed});

  final VoidCallback? onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'profileScreen.title'.tr(),
              style: AppTextStyles.semiBold().white
                  .s(22)
                  .copyWith(
                    color: AppColors.defaultPrimaryText,
                    height: 1,
                    letterSpacing: -0.31,
                  ),
            ),
            const Gap(10),
            Text(
              'profileScreen.manageAccount'.tr(),
              style: AppTextStyles.regular().white
                  .s(14)
                  .copyWith(
                    color: AppColors.defaultPrimaryText,
                    height: 20 / 14,
                    letterSpacing: -0.15,
                  ),
            ),
          ],
        ),
        IconButton(
          onPressed: onSettingsPressed,
          tooltip: 'profileScreen.settings'.tr(),
          icon: SvgPicture.asset(
            AssetsConstant.listSetting,
            width: 24,
            height: 24,
          ),
        ),
      ],
    );
  }
}
