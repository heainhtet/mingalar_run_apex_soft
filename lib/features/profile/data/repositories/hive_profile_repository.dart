import 'package:hive_ce/hive.dart';

import '../../../../core/database/hive_database.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/user_profile_hive_model.dart';

class HiveProfileRepository implements ProfileRepository {
  HiveProfileRepository(this._box);

  factory HiveProfileRepository.openedBox() {
    return HiveProfileRepository(
      Hive.box<UserProfileHiveModel>(HiveBoxNames.profile),
    );
  }

  final Box<UserProfileHiveModel> _box;

  @override
  Future<UserProfile?> getProfile() async {
    return _box.get(HiveKeys.currentUser)?.toEntity();
  }

  @override
  Future<void> saveProfile(UserProfile profile) {
    return _box.put(
      HiveKeys.currentUser,
      UserProfileHiveModel.fromEntity(profile),
    );
  }

  @override
  Future<void> deleteProfile() => _box.delete(HiveKeys.currentUser);
}
