import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';
import '../../domain/entities/user_profile.dart';
import 'rank_badge.dart';

Future<void> showScannedProfileDialog(
  BuildContext context, {
  required UserProfile profile,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppColors.black.withAlpha(166),
    transitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _ScannedProfileDialog(profile: profile);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.88, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _ScannedProfileDialog extends StatelessWidget {
  const _ScannedProfileDialog({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withAlpha(35),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 18, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'profileScreen.runnerProfile'.tr(),
                        style: AppTextStyles.semiBold()
                            .s(20)
                            .copyWith(
                              color: AppColors.cardLabelText,
                              height: 1.2,
                              letterSpacing: -0.31,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.cardLabelText,
                    ),
                  ],
                ),
                const Gap(18),
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: AppColors.tabIndicatorColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 46,
                    color: AppColors.defaultPrimaryText,
                  ),
                ),
                const Gap(14),
                Text(
                  profile.name,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.semiBold()
                      .s(22)
                      .copyWith(
                        color: AppColors.cardLabelText,
                        height: 1.25,
                        letterSpacing: -0.44,
                      ),
                ),
                const Gap(3),
                Text(
                  profile.phoneNumber,
                  style: AppTextStyles.regular()
                      .s(14)
                      .copyWith(
                        color: AppColors.scoreSumLabelTextColor,
                        height: 20 / 14,
                        letterSpacing: -0.15,
                      ),
                ),
                const Gap(22),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tabIndicatorColor.withAlpha(14),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.tabIndicatorColor.withAlpha(32),
                    ),
                  ),
                  child: Row(
                    children: [
                      const RankBadge(),
                      const Gap(12),
                      Expanded(
                        child: _ProfileValue(
                          label: 'profileScreen.currentTier'.tr(),
                          value: profile.tier,
                        ),
                      ),
                      _ProfileValue(
                        label: 'profileScreen.ionPoints'.tr(),
                        value: '${profile.ionPoints}',
                        alignEnd: true,
                      ),
                    ],
                  ),
                ),
                const Gap(18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: AppColors.tabIndicatorColor,
                    ),
                    const Gap(6),
                    Text(
                      'profileScreen.validMingalarQr'.tr(),
                      style: AppTextStyles.medium()
                          .s(11)
                          .copyWith(
                            color: AppColors.tabIndicatorColor,
                            height: 1,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileValue extends StatelessWidget {
  const _ProfileValue({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.regular()
              .s(10)
              .copyWith(color: AppColors.scoreSumLabelTextColor, height: 1.2),
        ),
        const Gap(3),
        Text(
          value,
          style: AppTextStyles.bold()
              .s(20)
              .copyWith(color: AppColors.scoreTextColor, height: 1.2),
        ),
      ],
    );
  }
}
