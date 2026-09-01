import 'package:hive_ce/hive.dart';

import '../../domain/entities/run_activity.dart';

class RunActivityHiveModel {
  const RunActivityHiveModel({
    required this.id,
    required this.startedAtMilliseconds,
    required this.calories,
    required this.distanceKilometers,
    required this.durationMilliseconds,
    required this.paceMilliseconds,
    required this.steps,
  });

  factory RunActivityHiveModel.fromEntity(RunActivity activity) {
    return RunActivityHiveModel(
      id: activity.id,
      startedAtMilliseconds: activity.startedAt.millisecondsSinceEpoch,
      calories: activity.calories,
      distanceKilometers: activity.distanceKilometers,
      durationMilliseconds: activity.duration.inMilliseconds,
      paceMilliseconds: activity.pacePerKilometer.inMilliseconds,
      steps: activity.steps,
    );
  }

  final String id;
  final int startedAtMilliseconds;
  final int calories;
  final double distanceKilometers;
  final int durationMilliseconds;
  final int paceMilliseconds;
  final int steps;

  RunActivity toEntity() {
    return RunActivity(
      id: id,
      startedAt: DateTime.fromMillisecondsSinceEpoch(startedAtMilliseconds),
      calories: calories,
      distanceKilometers: distanceKilometers,
      duration: Duration(milliseconds: durationMilliseconds),
      pacePerKilometer: Duration(milliseconds: paceMilliseconds),
      steps: steps,
    );
  }
}

class RunActivityHiveAdapter extends TypeAdapter<RunActivityHiveModel> {
  static const int typeIdValue = 2;

  @override
  int get typeId => typeIdValue;

  @override
  RunActivityHiveModel read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var index = 0; index < fieldCount; index++)
        reader.readByte(): reader.read(),
    };

    return RunActivityHiveModel(
      id: fields[0] as String? ?? '',
      startedAtMilliseconds: fields[1] as int? ?? 0,
      calories: fields[2] as int? ?? 0,
      distanceKilometers: (fields[3] as num?)?.toDouble() ?? 0,
      durationMilliseconds: fields[4] as int? ?? 0,
      paceMilliseconds: fields[5] as int? ?? 0,
      steps: fields[6] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, RunActivityHiveModel object) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(object.id)
      ..writeByte(1)
      ..write(object.startedAtMilliseconds)
      ..writeByte(2)
      ..write(object.calories)
      ..writeByte(3)
      ..write(object.distanceKilometers)
      ..writeByte(4)
      ..write(object.durationMilliseconds)
      ..writeByte(5)
      ..write(object.paceMilliseconds)
      ..writeByte(6)
      ..write(object.steps);
  }
}
