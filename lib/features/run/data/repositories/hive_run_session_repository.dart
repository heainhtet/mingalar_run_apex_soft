import 'package:hive_ce/hive.dart';

import '../../../../core/database/hive_database.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/run_session_snapshot.dart';
import '../../domain/repositories/run_session_repository.dart';
import '../models/run_session_hive_model.dart';

class HiveRunSessionRepository implements RunSessionRepository {
  HiveRunSessionRepository(this._box);

  factory HiveRunSessionRepository.openedBox() => HiveRunSessionRepository(
    Hive.box<RunSessionHiveModel>(HiveBoxNames.runSession),
  );

  final Box<RunSessionHiveModel> _box;

  @override
  RunSessionSnapshot? readActiveSession() {
    final snapshot = _box.get(HiveKeys.activeRun);
    logger.i(
      snapshot == null
          ? 'No unfinished run session found'
          : 'Recovered unfinished run session as paused',
    );
    return snapshot?.toEntity();
  }

  @override
  Future<void> saveActiveSession(RunSessionSnapshot snapshot) async {
    await _box.put(
      HiveKeys.activeRun,
      RunSessionHiveModel.fromEntity(snapshot),
    );
    logger.d(
      'Run recovery saved: elapsed=${snapshot.elapsed.inSeconds}s, '
      'moving=${snapshot.movingElapsed.inSeconds}s, '
      'distance=${snapshot.distanceKilometers.toStringAsFixed(3)}km, '
      'steps=${snapshot.steps}',
    );
  }

  @override
  Future<void> clearActiveSession() async {
    await _box.delete(HiveKeys.activeRun);
    logger.i('Run recovery data cleared');
  }
}
