import 'package:hive_ce/hive.dart';

import '../../../../core/database/hive_database.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/run_activity.dart';
import '../../domain/repositories/run_activity_repository.dart';
import '../models/run_activity_hive_model.dart';

class HiveRunActivityRepository implements RunActivityRepository {
  HiveRunActivityRepository(this._box);

  factory HiveRunActivityRepository.openedBox() {
    return HiveRunActivityRepository(
      Hive.box<RunActivityHiveModel>(HiveBoxNames.runActivities),
    );
  }

  final Box<RunActivityHiveModel> _box;

  @override
  Future<List<RunActivity>> getActivities() async {
    final activities = _box.values.map((model) => model.toEntity()).toList();
    activities.sort(
      (first, second) => second.startedAt.compareTo(first.startedAt),
    );
    logger.d('Loaded ${activities.length} completed run records');
    return activities;
  }

  @override
  Future<void> saveActivity(RunActivity activity) async {
    await _box.put(activity.id, RunActivityHiveModel.fromEntity(activity));
    logger.i('Completed run persisted: id=${activity.id}');
  }

  @override
  Future<void> deleteActivity(String id) async {
    await _box.delete(id);
    logger.i('Completed run deleted: id=$id');
  }
}
