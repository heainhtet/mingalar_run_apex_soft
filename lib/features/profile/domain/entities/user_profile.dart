import 'dart:convert';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.phoneNumber,
    required this.tier,
    required this.ionPoints,
  });

  final String name;
  final String phoneNumber;
  final String tier;
  final int ionPoints;

  static const String initialTier = 'Gold';
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

  String get qrPayload => jsonEncode({
    'type': 'mingalar_run_profile',
    'name': name,
    'phoneNumber': phoneNumber,
    'tier': tier,
    'ionPoints': ionPoints,
  });
}
