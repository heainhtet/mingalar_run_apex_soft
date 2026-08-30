import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/common/widgets/primary_button_widget.dart';
import '../../../../core/constants/assets_constant.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';

class RunTimerCard extends StatelessWidget {
  const RunTimerCard({
    super.key,
    required this.onStartRunning,
    this.timeText = '00:00',
  });

  final VoidCallback onStartRunning;
  final String timeText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x80989898), width: 0.71),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A101828),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0x1A / 255),
            blurRadius: 10,
            spreadRadius: -6,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0x26 / 255),
            blurRadius: 25,
            spreadRadius: -5,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'runScreen.startYourRun'.tr(),
                  style: AppTextStyles.semiBold()
                      .s(18)
                      .copyWith(
                        color: AppColors.cardLabelText,
                        height: 28 / 18,
                        letterSpacing: -0.44,
                      ),
                ),
              ),
              SvgPicture.asset(AssetsConstant.upIcon, width: 24, height: 24),
            ],
          ),
          Text(
            'runScreen.motivation'.tr(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.regular()
                .s(14)
                .copyWith(
                  color: AppColors.cardDescriptionText,
                  height: 20 / 14,
                  letterSpacing: -0.15,
                ),
          ),
          const Spacer(),
          Center(
            child: Text(
              timeText,
              style: AppTextStyles.medium().white
                  .s(80)
                  .copyWith(
                    color: AppColors.counterTextColor,
                    height: 100 / 80,
                    letterSpacing: 0,
                  ),
            ),
          ),
          const Spacer(),
          PrimaryButtonWidget(
            text: 'runScreen.startRun'.tr(),
            onPressed: onStartRunning,
            height: 52,
            borderRadius: 30,
            backgroundColor: AppColors.primaryButtonColor,
            textColor: AppColors.defaultPrimaryText,
            textStyle: AppTextStyles.semiBold().white
                .s(18)
                .copyWith(
                  color: AppColors.defaultPrimaryText,
                  height: 20 / 18,
                  letterSpacing: 0,
                ),
          ),
        ],
      ),
    );
  }
}
