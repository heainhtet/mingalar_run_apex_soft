import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';

class RunModeCard extends StatelessWidget {
  const RunModeCard({super.key, required this.modeIndex})
    : assert(modeIndex == 1 || modeIndex == 2);

  final int modeIndex;

  @override
  Widget build(BuildContext context) {
    final content = _RunModeContent.forIndex(modeIndex);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context, lightAlpha: 24),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: content.iconGradient,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: Icon(content.icon, color: AppColors.white, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.titleKey.tr(),
                  style: AppTextStyles.semiBold().black
                      .s(16)
                      .copyWith(
                        color: AppColors.primaryText(context),
                        height: 1.25,
                        letterSpacing: -0.2,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  content.descriptionKey.tr(),
                  style: AppTextStyles.regular().black
                      .s(12)
                      .copyWith(
                        color: AppColors.secondaryText(context),
                        height: 1.45,
                        letterSpacing: -0.1,
                      ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.completeRecordColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'runScreen.liveTrackingReady'.tr(),
                      style: AppTextStyles.medium().black
                          .s(10)
                          .copyWith(
                            color: AppColors.secondaryText(context),
                            height: 1,
                            letterSpacing: 0,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RunModeContent {
  const _RunModeContent({
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.iconGradient,
  });

  factory _RunModeContent.forIndex(int index) => index == 1 ? fun : challenge;

  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final List<Color> iconGradient;

  static const fun = _RunModeContent(
    titleKey: 'runScreen.funModeTitle',
    descriptionKey: 'runScreen.funModeDescription',
    icon: Icons.celebration_outlined,
    iconGradient: [AppColors.tabIndicatorColor, AppColors.runGradientEnd],
  );

  static const challenge = _RunModeContent(
    titleKey: 'runScreen.challengeModeTitle',
    descriptionKey: 'runScreen.challengeModeDescription',
    icon: Icons.emoji_events_outlined,
    iconGradient: [Color(0xFFFFB000), Color(0xFFFF6B00)],
  );
}
