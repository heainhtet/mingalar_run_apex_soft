class RunActivity {
  const RunActivity({
    required this.id,
    required this.startedAt,
    required this.calories,
    required this.distanceKilometers,
    required this.duration,
    required this.pacePerKilometer,
    this.steps = 0,
  }) : assert(calories >= 0),
       assert(distanceKilometers >= 0),
       assert(steps >= 0);

  final String id;
  final DateTime startedAt;
  final int calories;
  final double distanceKilometers;
  final Duration duration;
  final Duration pacePerKilometer;
  final int steps;
}
