import '../../domain/entities/user_profile.dart';

export '../../domain/entities/user_profile.dart';

enum ProfileSummaryType { totalRuns, longestDistance, totalCalories, bestPace }

class ProfileSummaryMetric {
  const ProfileSummaryMetric({
    required this.type,
    required this.labelKey,
    required this.value,
    this.unit = '',
  });

  final ProfileSummaryType type;
  final String labelKey;
  final String value;
  final String unit;
}

class ProfileState {
  const ProfileState({
    this.user,
    this.isEditing = false,
    this.isSaving = false,
  });

  final UserProfile? user;
  final bool isEditing;
  final bool isSaving;

  ProfileState copyWith({UserProfile? user, bool? isEditing, bool? isSaving}) {
    return ProfileState(
      user: user ?? this.user,
      isEditing: isEditing ?? this.isEditing,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
