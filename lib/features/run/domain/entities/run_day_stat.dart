/// Aggregated run statistics for a single calendar day.
///
/// When `hasActivity` is `false`, all metric fields keep their zero defaults,
/// which lets the UI render a "no activity" day without branching on nulls.
class RunDayStat {
  const RunDayStat({
    required this.date,
    required this.hasActivity,
    this.calories = 0,
    this.distanceKilometers = 0,
    this.duration = Duration.zero,
    this.pacePerKilometer,
    this.steps = 0,
    this.activityCount = 0,
  }) : assert(calories >= 0),
       assert(distanceKilometers >= 0),
       assert(steps >= 0),
       assert(activityCount >= 0);

  final DateTime date;
  final bool hasActivity;
  final int calories;
  final double distanceKilometers;
  final Duration duration;
  final Duration? pacePerKilometer;
  final int steps;
  final int activityCount;
}
