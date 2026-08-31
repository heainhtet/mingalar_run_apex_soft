import '../entities/run_sensor_frame.dart';

/// Turns native step timing and optional platform activity hints into a stable
/// movement state for a live run.
///
/// A single step signal is deliberately insufficient: it can be produced by a
/// brief shake. Three plausibly spaced hardware step events are required before
/// the session starts accumulating moving time or calories.
class RunMotionClassifier {
  static const confirmationWindow = Duration(seconds: 4);
  static const inactivityTimeout = Duration(seconds: 3);
  static const minimumConfirmedSteps = 3;
  static const _minimumStepInterval = Duration(milliseconds: 250);
  static const _maximumStepInterval = Duration(milliseconds: 1500);
  static const _stillConfidenceThreshold = 75;

  final List<DateTime> _detectorSteps = [];
  final List<_StepBurst> _counterBursts = [];

  NativeMotionActivity _activity = NativeMotionActivity.unknown;
  int _activityConfidence = 0;
  DateTime? _activityAt;
  double _platformCadence = 0;
  bool _hasStepDetectorSignals = false;

  bool get hasStepDetectorSignals => _hasStepDetectorSignals;

  void reset() {
    _detectorSteps.clear();
    _counterBursts.clear();
    _activity = NativeMotionActivity.unknown;
    _activityConfidence = 0;
    _activityAt = null;
    _platformCadence = 0;
    _hasStepDetectorSignals = false;
  }

  /// Records a single hardware step detector event (Android).
  void recordStepDetector(DateTime recordedAt) {
    final previous = _detectorSteps.isEmpty ? null : _detectorSteps.last;
    if (previous != null) {
      final interval = recordedAt.difference(previous);
      if (interval < _minimumStepInterval) {
        return;
      }
      if (interval > _maximumStepInterval) _detectorSteps.clear();
    }
    _hasStepDetectorSignals = true;
    _detectorSteps.add(recordedAt);
    _prune(recordedAt);
  }

  /// Uses an OS pedometer update when individual detector events are not
  /// available, notably on iOS where Core Motion supplies cadence directly.
  void recordPedometerDelta({
    required int stepDelta,
    required DateTime recordedAt,
    double cadenceStepsPerMinute = 0,
  }) {
    if (_hasStepDetectorSignals || stepDelta <= 0) return;
    _counterBursts.add(_StepBurst(recordedAt, stepDelta));
    updateCadence(cadenceStepsPerMinute);
    _prune(recordedAt);
  }

  void updateCadence(double cadenceStepsPerMinute) {
    if (!cadenceStepsPerMinute.isFinite || cadenceStepsPerMinute <= 0) return;
    _platformCadence = cadenceStepsPerMinute.clamp(0, 220).toDouble();
  }

  void updateActivity({
    required NativeMotionActivity activity,
    required int confidence,
    required DateTime recordedAt,
  }) {
    _activity = activity;
    _activityConfidence = confidence.clamp(0, 100);
    _activityAt = recordedAt;
  }

  MotionClassification classify(DateTime now) {
    _prune(now);
    final lastStepAt = _lastStepAt;
    final recentStepCount = _recentStepCount;
    if (lastStepAt == null ||
        recentStepCount < minimumConfirmedSteps ||
        now.difference(lastStepAt) > inactivityTimeout) {
      return const MotionClassification.stopped();
    }

    // A recent high-confidence stationary result is stronger than an older
    // burst, while a stale stationary result never blocks a real walk.
    final activityAt = _activityAt;
    if (_activity == NativeMotionActivity.still &&
        _activityConfidence >= _stillConfidenceThreshold &&
        activityAt != null &&
        !activityAt.isBefore(lastStepAt)) {
      return const MotionClassification.stopped();
    }

    return MotionClassification.walking(cadenceStepsPerMinute: _cadence);
  }

  DateTime? get _lastStepAt => _hasStepDetectorSignals
      ? (_detectorSteps.isEmpty ? null : _detectorSteps.last)
      : (_counterBursts.isEmpty ? null : _counterBursts.last.recordedAt);

  int get _recentStepCount => _hasStepDetectorSignals
      ? _detectorSteps.length
      : _counterBursts.fold(0, (sum, burst) => sum + burst.stepCount);

  double get _cadence {
    if (!_hasStepDetectorSignals) return _platformCadence;
    if (_detectorSteps.length < minimumConfirmedSteps) return 0;

    final intervals = <int>[];
    for (var index = 1; index < _detectorSteps.length; index++) {
      final milliseconds = _detectorSteps[index]
          .difference(_detectorSteps[index - 1])
          .inMilliseconds;
      if (milliseconds >= _minimumStepInterval.inMilliseconds &&
          milliseconds <= _maximumStepInterval.inMilliseconds) {
        intervals.add(milliseconds);
      }
    }
    if (intervals.length < minimumConfirmedSteps - 1) return 0;
    intervals.sort();
    final median = intervals[intervals.length ~/ 2];
    return (Duration.millisecondsPerMinute / median).clamp(0, 220).toDouble();
  }

  void _prune(DateTime now) {
    final cutoff = now.subtract(confirmationWindow);
    _detectorSteps.removeWhere((at) => at.isBefore(cutoff));
    _counterBursts.removeWhere((burst) => burst.recordedAt.isBefore(cutoff));
  }
}

class MotionClassification {
  const MotionClassification._({
    required this.pedestrianState,
    required this.cadenceStepsPerMinute,
  });

  const MotionClassification.stopped()
    : this._(
        pedestrianState: PedestrianState.stopped,
        cadenceStepsPerMinute: 0,
      );

  const MotionClassification.walking({required double cadenceStepsPerMinute})
    : this._(
        pedestrianState: PedestrianState.walking,
        cadenceStepsPerMinute: cadenceStepsPerMinute,
      );

  final PedestrianState pedestrianState;
  final double cadenceStepsPerMinute;
}

class _StepBurst {
  const _StepBurst(this.recordedAt, this.stepCount);

  final DateTime recordedAt;
  final int stepCount;
}
