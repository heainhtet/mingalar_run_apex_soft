import 'dart:convert';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.phoneNumber,
    required this.tier,
    required this.ionPoints,
    this.avatarPath,
  });

  final String name;
  final String phoneNumber;
  final String tier;
  final int ionPoints;
  final String? avatarPath;

  static const String initialTier = 'Bronze';
  static const int initialIonPoints = 0;

  factory UserProfile.newRunner({
    required String name,
    required String phoneNumber,
  }) {
    return UserProfile(
      name: name,
      phoneNumber: phoneNumber,
      tier: initialTier,
      ionPoints: initialIonPoints,
    );
  }

  UserProfile copyWith({
    String? name,
    String? phoneNumber,
    String? tier,
    int? ionPoints,
    String? avatarPath,
    bool removeAvatar = false,
  }) {
    return UserProfile(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      tier: tier ?? this.tier,
      ionPoints: ionPoints ?? this.ionPoints,
      avatarPath: removeAvatar ? null : avatarPath ?? this.avatarPath,
    );
  }

  static UserProfile? tryParseQrPayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic> ||
          decoded['type'] != 'mingalar_run_profile') {
        return null;
      }

      final name = decoded['name'];
      final phoneNumber = decoded['phoneNumber'];
      final tier = decoded['tier'];
      final ionPoints = decoded['ionPoints'];
      if (name is! String ||
          name.trim().isEmpty ||
          phoneNumber is! String ||
          phoneNumber.trim().isEmpty ||
          tier is! String ||
          tier.trim().isEmpty ||
          ionPoints is! num ||
          ionPoints < 0) {
        return null;
      }

      return UserProfile(
        name: name.trim(),
        phoneNumber: phoneNumber.trim(),
        tier: tier.trim(),
        ionPoints: ionPoints.toInt(),
      );
    } on FormatException {
      return null;
    }
  }

  String get qrPayload => qrPayloadFor(tier: tier, ionPoints: ionPoints);

  String qrPayloadFor({required String tier, required int ionPoints}) =>
      jsonEncode({
        'type': 'mingalar_run_profile',
        'version': 1,
        'name': name,
        'phoneNumber': phoneNumber,
        'tier': tier,
        'ionPoints': ionPoints,
      });
}
