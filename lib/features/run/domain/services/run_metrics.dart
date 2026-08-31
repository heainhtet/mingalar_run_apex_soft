import '../entities/run_stage.dart';

abstract final class RunMetrics {
  static const double defaultWeightKg = 70;

  static Duration? paceFor(double distanceKilometers, Duration elapsed) {
    if (distanceKilometers <= 0 || elapsed <= Duration.zero) return null;
    return Duration(
      milliseconds: (elapsed.inMilliseconds / distanceKilometers).round(),
    );
  }

  static double caloriesExactFor(
    RunStage stage,
    Duration elapsed, {
    double weightKg = defaultWeightKg,
  }) {
    if (elapsed <= Duration.zero || weightKg <= 0) return 0;
    final minutes = elapsed.inMilliseconds / Duration.millisecondsPerMinute;
    return stage.met * 3.5 * weightKg / 200 * minutes;
  }

  static int caloriesFor(RunStage stage, Duration elapsed) =>
      caloriesExactFor(stage, elapsed).round();
}
