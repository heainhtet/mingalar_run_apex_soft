import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/assets_constant.dart';
import 'home_feature_challenge_card.dart';
import 'home_section_header.dart';

class HomeFeaturedChallengesSection extends StatelessWidget {
  const HomeFeaturedChallengesSection({super.key, this.onShowMore});

  final VoidCallback? onShowMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(
          title: 'homeScreen.featuredChallenges'.tr(),
          actionLabel: 'homeScreen.showMore'.tr(),
          onActionPressed: onShowMore,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: HomeFeatureChallengeCard.size.height,
          child: PageView.builder(
            key: const PageStorageKey('home-featured-challenges'),
            physics: const BouncingScrollPhysics(),
            itemCount: _challengeAssets.length,
            itemBuilder: (context, index) {
              return Align(
                alignment: Alignment.centerLeft,
                child: HomeFeatureChallengeCard(
                  assetPath: _challengeAssets[index],
                  onTap: onShowMore,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

const _challengeAssets = [
  AssetsConstant.featuredChallenge,
  AssetsConstant.consistencyRun,
];
