import 'run_stage.dart';

class RunSessionSnapshot {
  const RunSessionSnapshot({
    required this.startedAt,
    required this.elapsed,
    Duration? movingElapsed,
    required this.distanceKilometers,
    required this.caloriesExact,
    required this.steps,
    required this.stage,
  }) : movingElapsed = movingElapsed ?? elapsed;

  final DateTime startedAt;
  final Duration elapsed;
  final Duration movingElapsed;
  final double distanceKilometers;
  final double caloriesExact;
  final int steps;
  final RunStage stage;
}
