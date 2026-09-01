import '../../../run/domain/entities/run_activity.dart';

/// A runner's local progression is derived from completed activities.
///
/// Ten verified steps earn one ION point. When a completed legacy activity has
/// no step total, each verified ten metres earns one point instead.
enum ProfileTier {
  bronze('Bronze', 0),
  silver('Silver', 1000),
  gold('Gold', 5000),
  platinum('Platinum', 15000),
  diamond('Diamond', 40000);

  const ProfileTier(this.label, this.minimumPoints);

  final String label;
  final int minimumPoints;

  static ProfileTier fromLabel(String value) {
    return ProfileTier.values.firstWhere(
      (tier) => tier.label.toLowerCase() == value.toLowerCase(),
      orElse: () => ProfileTier.bronze,
    );
  }
}

class ProfileRank {
  const ProfileRank({required this.tier, required this.ionPoints});

  factory ProfileRank.fromActivities(List<RunActivity> activities) {
    final points = activities.fold<int>(0, (total, activity) {
      final activityPoints = activity.steps > 0
          ? activity.steps ~/ 10
          : (activity.distanceKilometers * 100).round();
      return total + activityPoints;
    });
    final tier = ProfileTier.values.lastWhere(
      (candidate) => points >= candidate.minimumPoints,
    );
    return ProfileRank(tier: tier, ionPoints: points);
  }

  final ProfileTier tier;
  final int ionPoints;

  ProfileTier? get nextTier {
    final index = ProfileTier.values.indexOf(tier);
    if (index == ProfileTier.values.length - 1) return null;
    return ProfileTier.values[index + 1];
  }

  int get pointsToNextTier =>
      nextTier == null ? 0 : nextTier!.minimumPoints - ionPoints;
}
