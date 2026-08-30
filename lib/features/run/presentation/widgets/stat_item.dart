import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';

class StatItem extends StatelessWidget {
  const StatItem({super.key, required this.assetPath, required this.value});

  final String assetPath;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(assetPath, width: 14, height: 14),
        const Gap(4),
        Text(
          value,
          style: AppTextStyles.regular().white
              .s(10)
              .copyWith(
                color: AppColors.defaultPrimaryText,
                height: 12 / 10,
                letterSpacing: 0,
              ),
        ),
      ],
    );
  }
}
