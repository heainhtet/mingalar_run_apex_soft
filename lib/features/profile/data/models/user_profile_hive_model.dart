import 'package:hive_ce/hive.dart';

import '../../domain/entities/user_profile.dart';

class UserProfileHiveModel {
  const UserProfileHiveModel({
    required this.name,
    required this.phoneNumber,
    required this.tier,
    required this.ionPoints,
  });

  factory UserProfileHiveModel.fromEntity(UserProfile profile) {
    return UserProfileHiveModel(
      name: profile.name,
      phoneNumber: profile.phoneNumber,
      tier: profile.tier,
      ionPoints: profile.ionPoints,
    );
  }

  final String name;
  final String phoneNumber;
  final String tier;
  final int ionPoints;

  UserProfile toEntity() {
    return UserProfile(
      name: name,
      phoneNumber: phoneNumber,
      tier: tier,
      ionPoints: ionPoints,
    );
  }
}

class UserProfileHiveAdapter extends TypeAdapter<UserProfileHiveModel> {
  /// Type IDs and field numbers are persisted on disk. Existing IDs must never
  /// be reused, and new fields must be appended without renumbering old fields.
  static const int typeIdValue = 1;

  @override
  int get typeId => typeIdValue;

  @override
  UserProfileHiveModel read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var index = 0; index < fieldCount; index++)
        reader.readByte(): reader.read(),
    };

    return UserProfileHiveModel(
      name: fields[0] as String? ?? '',
      phoneNumber: fields[1] as String? ?? '',
      tier: fields[2] as String? ?? UserProfile.initialTier,
      ionPoints: fields[3] as int? ?? UserProfile.initialIonPoints,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileHiveModel object) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(object.name)
      ..writeByte(1)
      ..write(object.phoneNumber)
      ..writeByte(2)
      ..write(object.tier)
      ..writeByte(3)
      ..write(object.ionPoints);
  }
}
