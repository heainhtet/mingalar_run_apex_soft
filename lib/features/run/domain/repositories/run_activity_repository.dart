import '../entities/run_activity.dart';

abstract interface class RunActivityRepository {
  Future<List<RunActivity>> getActivities();

  Future<void> saveActivity(RunActivity activity);

  Future<void> deleteActivity(String id);
}
