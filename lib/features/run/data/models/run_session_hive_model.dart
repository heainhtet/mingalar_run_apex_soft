import 'package:hive_ce/hive.dart';

import '../../domain/entities/run_session_snapshot.dart';
import '../../domain/entities/run_stage.dart';

class RunSessionHiveModel {
  const RunSessionHiveModel({
    required this.startedAtMilliseconds,
    required this.elapsedMilliseconds,
    required this.movingElapsedMilliseconds,
    required this.distanceKilometers,
    required this.caloriesExact,
    required this.steps,
    required this.stageIndex,
  });

  factory RunSessionHiveModel.fromEntity(RunSessionSnapshot value) =>
      RunSessionHiveModel(
        startedAtMilliseconds: value.startedAt.millisecondsSinceEpoch,
        elapsedMilliseconds: value.elapsed.inMilliseconds,
        movingElapsedMilliseconds: value.movingElapsed.inMilliseconds,
        distanceKilometers: value.distanceKilometers,
        caloriesExact: value.caloriesExact,
        steps: value.steps,
        stageIndex: value.stage.index,
      );

  final int startedAtMilliseconds;
  final int elapsedMilliseconds;
  final int movingElapsedMilliseconds;
  final double distanceKilometers;
  final double caloriesExact;
  final int steps;
  final int stageIndex;

  RunSessionSnapshot toEntity() => RunSessionSnapshot(
    startedAt: DateTime.fromMillisecondsSinceEpoch(startedAtMilliseconds),
    elapsed: Duration(milliseconds: elapsedMilliseconds),
    movingElapsed: Duration(milliseconds: movingElapsedMilliseconds),
    distanceKilometers: distanceKilometers,
    caloriesExact: caloriesExact,
    steps: steps,
    stage: RunStage.values.elementAtOrNull(stageIndex) ?? RunStage.stopped,
  );
}

class RunSessionHiveAdapter extends TypeAdapter<RunSessionHiveModel> {
  static const int typeIdValue = 3;

  @override
  int get typeId => typeIdValue;

  @override
  RunSessionHiveModel read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{
      for (var index = 0; index < count; index++)
        reader.readByte(): reader.read(),
    };
    return RunSessionHiveModel(
      startedAtMilliseconds: fields[0] as int? ?? 0,
      elapsedMilliseconds: fields[1] as int? ?? 0,
      movingElapsedMilliseconds: fields[6] as int? ?? fields[1] as int? ?? 0,
      distanceKilometers: (fields[2] as num?)?.toDouble() ?? 0,
      caloriesExact: (fields[3] as num?)?.toDouble() ?? 0,
      steps: fields[4] as int? ?? 0,
      stageIndex: fields[5] as int? ?? RunStage.stopped.index,
    );
  }

  @override
  void write(BinaryWriter writer, RunSessionHiveModel object) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(object.startedAtMilliseconds)
      ..writeByte(1)
      ..write(object.elapsedMilliseconds)
      ..writeByte(2)
      ..write(object.distanceKilometers)
      ..writeByte(3)
      ..write(object.caloriesExact)
      ..writeByte(4)
      ..write(object.steps)
      ..writeByte(5)
      ..write(object.stageIndex)
      ..writeByte(6)
      ..write(object.movingElapsedMilliseconds);
  }
}
