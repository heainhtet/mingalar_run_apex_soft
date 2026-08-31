import 'package:mingalar_un/features/profile/domain/entities/user_profile.dart';
import 'package:mingalar_un/features/profile/domain/repositories/profile_repository.dart';
import 'package:mingalar_un/features/run/domain/entities/run_activity.dart';
import 'package:mingalar_un/features/run/domain/entities/run_session_snapshot.dart';
import 'package:mingalar_un/features/run/domain/repositories/run_activity_repository.dart';
import 'package:mingalar_un/features/run/domain/repositories/run_session_repository.dart';

class InMemoryProfileRepository implements ProfileRepository {
  InMemoryProfileRepository({UserProfile? initialProfile})
    : _profile = initialProfile;

  UserProfile? _profile;

  @override
  Future<UserProfile?> getProfile() async => _profile;

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
  }

  @override
  Future<void> deleteProfile() async {
    _profile = null;
  }
}

class InMemoryRunSessionRepository implements RunSessionRepository {
  InMemoryRunSessionRepository([this.snapshot]);

  RunSessionSnapshot? snapshot;

  @override
  RunSessionSnapshot? readActiveSession() => snapshot;

  @override
  Future<void> saveActiveSession(RunSessionSnapshot value) async {
    snapshot = value;
  }

  @override
  Future<void> clearActiveSession() async {
    snapshot = null;
  }
}

class InMemoryRunActivityRepository implements RunActivityRepository {
  InMemoryRunActivityRepository([List<RunActivity> activities = const []])
    : _activities = [...activities];

  final List<RunActivity> _activities;

  @override
  Future<List<RunActivity>> getActivities() async {
    return [..._activities]
      ..sort((first, second) => second.startedAt.compareTo(first.startedAt));
  }

  @override
  Future<void> saveActivity(RunActivity activity) async {
    _activities.removeWhere((existing) => existing.id == activity.id);
    _activities.add(activity);
  }

  @override
  Future<void> deleteActivity(String id) async {
    _activities.removeWhere((activity) => activity.id == id);
  }
}
