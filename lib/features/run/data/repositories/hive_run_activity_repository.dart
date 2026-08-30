import 'package:hive_ce/hive.dart';

import '../../../../core/database/hive_database.dart';
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
    return activities;
  }

  @override
  Future<void> saveActivity(RunActivity activity) {
    return _box.put(activity.id, RunActivityHiveModel.fromEntity(activity));
  }

  @override
  Future<void> deleteActivity(String id) => _box.delete(id);
}
