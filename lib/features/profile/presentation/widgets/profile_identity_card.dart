import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/assets_constant.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';
import '../models/profile_models.dart';
import '../../domain/entities/profile_rank.dart';
import 'dashed_divider.dart';
import 'profile_avatar.dart';
import 'rank_badge.dart';

class ProfileIdentityCard extends StatelessWidget {
  const ProfileIdentityCard({
    super.key,
    required this.user,
    required this.onQrPressed,
    required this.onAvatarPressed,
    required this.rank,
  });

  final UserProfile? user;
  final VoidCallback onQrPressed;
  final VoidCallback onAvatarPressed;
  final ProfileRank rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(26),
            offset: const Offset(0, 1),
            blurRadius: 2,
            spreadRadius: -1,
          ),
          BoxShadow(
            color: AppColors.black.withAlpha(26),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ProfileAvatar(
                avatarPath: user?.avatarPath,
                size: 62,
                onTap: onAvatarPressed,
              ),
              const Gap(14),
              Expanded(child: _UserDetails(user: user)),
              const Gap(8),
              _QrAction(onPressed: onQrPressed),
            ],
          ),
          const Gap(16),
          DashedDivider(color: AppColors.scoreSumLabelTextColor.withAlpha(77)),
          const Gap(16),
          _RankDetails(rank: rank),
        ],
      ),
    );
  }
}

class _UserDetails extends StatelessWidget {
  const _UserDetails({required this.user});

  final UserProfile? user;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user?.name ?? 'profileScreen.addInformation'.tr(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.semiBold().black
              .s(20)
              .copyWith(
                color: AppColors.cardLabelText,
                height: 28 / 20,
                letterSpacing: -0.44,
              ),
        ),
        Text(
          user?.phoneNumber ?? 'profileScreen.tapQrToBegin'.tr(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.regular().black
              .s(14)
              .copyWith(
                color: AppColors.scoreSumLabelTextColor,
                height: 20 / 14,
                letterSpacing: -0.15,
              ),
        ),
      ],
    );
  }
}

class _QrAction extends StatelessWidget {
  const _QrAction({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(AssetsConstant.qrCode, width: 24, height: 24),
            Text(
              'profileScreen.myQr'.tr(),
              style: AppTextStyles.regular().black
                  .s(10)
                  .copyWith(
                    color: AppColors.defaultBlackText,
                    height: 24 / 10,
                    letterSpacing: -0.15,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankDetails extends StatelessWidget {
  const _RankDetails({required this.rank});

  final ProfileRank rank;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RankBadge(tier: rank.tier),
        const Gap(10),
        Expanded(
          child: _RankValue(
            label: 'profileScreen.currentTier'.tr(),
            value: rank.tier.label,
          ),
        ),
        _RankValue(
          label: 'profileScreen.ionPoints'.tr(),
          value: '${rank.ionPoints}',
          alignRight: true,
        ),
      ],
    );
  }
}

class _RankValue extends StatelessWidget {
  const _RankValue({
    required this.label,
    required this.value,
    this.alignRight = false,
  });

  final String label;
  final String value;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.regular().black
              .s(10)
              .copyWith(
                color: AppColors.scoreTextColor.withAlpha(77),
                height: 16 / 10,
                letterSpacing: -0.1,
              ),
        ),
        Text(
          value,
          style: AppTextStyles.bold().black
              .s(24)
              .copyWith(
                color: AppColors.scoreTextColor,
                height: 32 / 24,
                letterSpacing: -0.3,
              ),
        ),
      ],
    );
  }
}
