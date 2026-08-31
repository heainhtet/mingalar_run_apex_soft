/// Plugin-independent pedestrian state used by the domain layer.
enum PedestrianState { walking, stopped, unknown }

/// High-level movement hint supplied by the operating system.
///
/// It confirms hardware step timing but never creates a step or distance.
enum NativeMotionActivity { still, walking, running, unknown }

/// Identifies the hardware path that supplied the current session step count.
enum StepDataSource { nativeMotion, unavailable }

/// Normalized snapshot emitted whenever location or motion data changes.
class RunSensorFrame {
  const RunSensorFrame({
    required this.latitude,
    required this.longitude,
    required this.speedMetersPerSecond,
    required this.accuracyMeters,
    this.steps = 0,
    this.cadenceStepsPerMinute = 0,
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

  /// Cumulative steps for the current active sensor segment.
  final int steps;

  /// Observed steps per minute, or zero when cadence is unavailable.
  final double cadenceStepsPerMinute;

  /// Confirmed pedestrian state derived from native step timing.
  final PedestrianState pedestrianStatus;
  final StepDataSource stepSource;
  final DateTime? recordedAt;
  final bool hasStepData;
  final bool hasLocationData;
  final bool isLocationUpdate;

  /// Speed expressed in kilometres per hour.
  double get speedKmh => speedMetersPerSecond * 3.6;

  /// True when the frame is accurate enough to be trusted for distance.
  bool get isUsable =>
      hasLocationData &&
      latitude.isFinite &&
      longitude.isFinite &&
      accuracyMeters.isFinite &&
      accuracyMeters >= 0 &&
      accuracyMeters <= 30;
}
