import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/assets_constant.dart';
import '../models/challenge_preview.dart';

final featuredChallengesProvider = Provider<List<ChallengePreview>>((ref) {
  return const [
    ChallengePreview(
      titleKey: 'challenges.forest.title',
      descriptionKey: 'challenges.forest.description',
      assetPath: AssetsConstant.featuredChallenge,
      badgeKey: 'challenges.featured',
      distance: '5 km',
      duration: '7 days',
    ),
    ChallengePreview(
      titleKey: 'challenges.city.title',
      descriptionKey: 'challenges.city.description',
      assetPath: AssetsConstant.eventOne,
      badgeKey: 'challenges.popular',
      distance: '10 km',
      duration: '14 days',
    ),
    ChallengePreview(
      titleKey: 'challenges.consistency.title',
      descriptionKey: 'challenges.consistency.description',
      assetPath: AssetsConstant.consistencyRun,
      badgeKey: 'challenges.newLabel',
      distance: '20 km',
      duration: '30 days',
    ),
  ];
});
