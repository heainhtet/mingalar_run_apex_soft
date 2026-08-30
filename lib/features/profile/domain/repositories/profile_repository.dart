import '../entities/user_profile.dart';

abstract interface class ProfileRepository {
  Future<UserProfile?> getProfile();

  Future<void> saveProfile(UserProfile profile);

  Future<void> deleteProfile();
}
