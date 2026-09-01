enum PedestrianState { walking, stopped, unknown }

enum StepDataSource { cmPedometer, androidPedometer, unavailable }

class RunSensorFrame {
  const RunSensorFrame({
    required this.latitude,
    required this.longitude,
    required this.speedMetersPerSecond,
    required this.accuracyMeters,
    this.steps = 0,
    this.cadenceStepsPerMinute = 0,
    this.nativeDistanceKilometers,
    this.nativePacePerKilometer,
    this.usesNativePedometerMetrics = false,
    this.pedestrianStatus = PedestrianState.unknown,
    this.stepSource = StepDataSource.unavailable,
    this.recordedAt,
    this.hasStepData = false,
    this.hasLocationData = true,
    this.isLocationUpdate = true,
  });

  final double latitude;
  final double longitude;
  final double speedMetersPerSecond;
  final double accuracyMeters;

  final int steps;

  final double cadenceStepsPerMinute;

  final double? nativeDistanceKilometers;

  final Duration? nativePacePerKilometer;

  final bool usesNativePedometerMetrics;

  final PedestrianState pedestrianStatus;
  final StepDataSource stepSource;
  final DateTime? recordedAt;
  final bool hasStepData;
  final bool hasLocationData;
  final bool isLocationUpdate;

  double get speedKmh => speedMetersPerSecond * 3.6;

  bool get isUsable =>
      hasLocationData &&
      latitude.isFinite &&
      longitude.isFinite &&
      accuracyMeters.isFinite &&
      accuracyMeters >= 0 &&
      accuracyMeters <= 30;
}
