import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';

class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.semiBold().white
          .s(18)
          .copyWith(
            color: AppColors.defaultPrimaryText,
            height: 16 / 18,
            letterSpacing: 0,
          ),
    );
  }
}
