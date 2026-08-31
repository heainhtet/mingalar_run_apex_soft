import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../data/repositories/hive_run_session_repository.dart';
import '../../data/services/geolocator_run_sensor_service.dart';
import '../../domain/entities/run_sensor_frame.dart';
import '../../domain/entities/run_session_snapshot.dart';
import '../../domain/entities/run_stage.dart';
import '../../domain/repositories/run_session_repository.dart';
import '../../domain/services/gps_distance_accumulator.dart';
import '../../domain/services/run_metrics.dart';
import '../../domain/services/run_sensor_service.dart';
import '../models/run_session_state.dart';
import 'run_providers.dart';

export '../../domain/entities/run_stage.dart';
export '../../domain/services/run_metrics.dart';
export '../models/run_session_state.dart';

final runSensorServiceProvider = Provider<RunSensorService>(
  (ref) => GeolocatorRunSensorService(),
);
final runSessionRepositoryProvider = Provider<RunSessionRepository>(
  (ref) => HiveRunSessionRepository.openedBox(),
);
final runNowProvider = Provider<DateTime Function()>((ref) => DateTime.now);
final runSessionProvider =
    NotifierProvider<RunSessionNotifier, RunSessionState>(
      RunSessionNotifier.new,
    );

class RunSessionNotifier extends Notifier<RunSessionState> {
  static const _recoveryWriteInterval = Duration(seconds: 5);
  static const _minimumSavedDuration = Duration(seconds: 10);
  static const _minimumSavedDistanceKm = 0.01;
  static const _minimumSavedSteps = 10;
  StreamSubscription<RunSensorFrame>? _sensorSubscription;
  Timer? _ticker;
  DateTime? _segmentStartedAt;
  DateTime? _lastMetricAt;
  DateTime? _lastRecoveryWriteAt;
  DateTime? _lastDebugLogAt;
  Duration _completedActiveTime = Duration.zero;
  Duration _movingElapsed = Duration.zero;
  double _caloriesExact = 0;
  final GpsDistanceAccumulator _gpsDistance = GpsDistanceAccumulator();
  int _stepsBeforeSegment = 0;
  Future<void> _sensorCleanup = Future.value();
  late RunSensorService _sensorService;
  late RunSessionRepository _activeSessionRepository;

  DateTime get _now => ref.read(runNowProvider)();
  RunSensorService get _sensor => _sensorService;
  RunSessionRepository get _sessionRepository => _activeSessionRepository;

  @override
  RunSessionState build() {
    final sensorService = ref.read(runSensorServiceProvider);
    _sensorService = sensorService;
    _activeSessionRepository = ref.read(runSessionRepositoryProvider);
    ref.onDispose(() => unawaited(_stopSensors(sensorService: sensorService)));
    final snapshot = _sessionRepository.readActiveSession();
    if (snapshot == null) return const RunSessionState();

    _completedActiveTime = snapshot.elapsed;
    _movingElapsed = snapshot.movingElapsed;
    _caloriesExact = snapshot.caloriesExact;
    _gpsDistance.reset(initialDistanceKilometers: snapshot.distanceKilometers);
    _stepsBeforeSegment = snapshot.steps;
    return RunSessionState(
      status: RunSessionStatus.paused,
      stage: snapshot.stage,
      startedAt: snapshot.startedAt,
      elapsed: snapshot.elapsed,
      distanceKilometers: snapshot.distanceKilometers,
      pacePerKilometer: RunMetrics.paceFor(
        snapshot.distanceKilometers,
        snapshot.movingElapsed,
      ),
      calories: snapshot.caloriesExact.round(),
      steps: snapshot.steps,
    );
  }

  Future<RunPermissionResult> start() async {
    if (!state.isIdle) return RunPermissionResult.granted;
    final permission = await _sensor.requestPermission();
    if (permission != RunPermissionResult.granted) return permission;

    final now = _now;
    _completedActiveTime = Duration.zero;
    _movingElapsed = Duration.zero;
    _caloriesExact = 0;
    _gpsDistance.reset();
    _stepsBeforeSegment = 0;
    _segmentStartedAt = now;
    _lastMetricAt = now;
    state = RunSessionState(status: RunSessionStatus.running, startedAt: now);
    logger.i('Run session started');
    await _persistRecovery(force: true);
    _listenToSensors();
    _startTicker();
    return RunPermissionResult.granted;
  }

  Future<bool> openLocationSettings() => _sensor.openLocationSettings();

  Future<bool> openAppSettings() => _sensor.openAppSettings();

  Future<void> pause() async {
    if (!state.isRunning) return;
    _closeActiveSegment(_now);
    state = state.copyWith(status: RunSessionStatus.paused);
    await _stopSensors();
    await _persistRecovery(force: true);
    logger.i('Run session paused at ${state.elapsed.inSeconds}s');
  }

  Future<void> resume() async {
    if (!state.isPaused) return;
    await _sensorCleanup;
    final now = _now;
    _stepsBeforeSegment = state.steps;
    _segmentStartedAt = now;
    _lastMetricAt = now;
    state = state.copyWith(
      status: RunSessionStatus.running,
      clearSensorError: true,
    );
    _listenToSensors();
    _startTicker();
    logger.i('Run session resumed');
  }

  Future<RunEndResult> end() async {
    if (state.isRunning) _closeActiveSegment(_now);
    await _stopSensors();
    final current = state.copyWith(
      status: RunSessionStatus.paused,
      isSaving: true,
    );
    state = current;

    final meaningful =
        current.elapsed >= _minimumSavedDuration &&
        (current.distanceKilometers >= _minimumSavedDistanceKm ||
            current.steps >= _minimumSavedSteps);
    if (!meaningful) {
      await _sessionRepository.clearActiveSession();
      state = const RunSessionState();
      logger.i('Empty run discarded instead of creating history');
      return RunEndResult.discarded;
    }

    try {
      await ref
          .read(runActivitiesProvider.notifier)
          .recordCompletedRun(
            startedAt: current.startedAt ?? _now,
            calories: current.calories,
            distanceKilometers: current.distanceKilometers,
            duration: current.elapsed,
            paceDuration: _movingElapsed,
            steps: current.steps,
          );
      await _sessionRepository.clearActiveSession();
      logger.i(
        'Run saved: duration=${current.elapsed.inSeconds}s, '
        'distance=${current.distanceKilometers.toStringAsFixed(3)}km, '
        'steps=${current.steps}, calories=${current.calories}',
      );
      state = const RunSessionState();
      return RunEndResult.saved;
    } catch (error, stackTrace) {
      state = current.copyWith(isSaving: false);
      await _persistRecovery(force: true);
      logger.e(
        'Failed to finalize run; recovery data retained',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> reset() async {
    await _stopSensors();
    await _sessionRepository.clearActiveSession();
    state = const RunSessionState();
    logger.i('Run session reset');
  }

  void _listenToSensors() {
    try {
      _sensorSubscription = _sensor.start().listen(
        _handleSensorFrame,
        onError: _handleSensorError,
      );
      logger.i('Run sensors started');
    } catch (error, stackTrace) {
      _handleSensorError(error, stackTrace);
    }
  }

  void _handleSensorFrame(RunSensorFrame frame) {
    if (!state.isRunning) return;
    final now = frame.recordedAt ?? _now;
    _advanceMetrics(now);

    final previousGpsDistance = _gpsDistance.distanceKilometers;
    final gpsDistanceKilometers = _gpsDistance.add(frame);
    final hasAcceptedGpsMovement = gpsDistanceKilometers > previousGpsDistance;
    final steps = frame.hasStepData
        ? math.max(state.steps, _stepsBeforeSegment + frame.steps)
        : state.steps;
    final stage = RunStage.classify(
      pedestrianWalking:
          frame.pedestrianStatus == PedestrianState.walking &&
          frame.hasStepData &&
          frame.steps > 0,
      cadence: frame.cadenceStepsPerMinute,
    );
    // Distance is GPS-derived. Step totals never manufacture metres because a
    // stride estimate would turn false hardware steps into a false route.
    final distance = gpsDistanceKilometers;
    final elapsed = _activeElapsed(now);
    state = state.copyWith(
      stage: stage,
      stepSource: frame.stepSource,
      elapsed: elapsed,
      distanceKilometers: distance,
      pacePerKilometer: RunMetrics.paceFor(distance, _movingElapsed),
      clearPace: distance <= 0,
      calories: _caloriesExact.round(),
      steps: steps,
    );
    if (_lastDebugLogAt == null ||
        now.difference(_lastDebugLogAt!) >= const Duration(seconds: 2)) {
      _lastDebugLogAt = now;
      logger.d(
        'Run data: stage=${stage.name}, elapsed=${elapsed.inSeconds}s, '
        'moving=${_movingElapsed.inSeconds}s, '
        'distance=${distance.toStringAsFixed(3)}km, steps=$steps, '
        'calories=${state.calories}, stepsSource=${frame.stepSource.name}, '
        'gpsDistanceAccepted=$hasAcceptedGpsMovement',
      );
    }
    unawaited(_persistRecovery());
  }

  void _handleSensorError(Object error, [StackTrace? stackTrace]) {
    if (!state.isRunning) return;
    _closeActiveSegment(_now);
    state = state.copyWith(
      status: RunSessionStatus.paused,
      sensorError: error.toString(),
    );
    _sensorCleanup = _stopSensors();
    unawaited(_persistRecovery(force: true));
    logger.e(
      'Run sensor failed; session paused safely',
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isRunning) return;
      final now = _now;
      _advanceMetrics(now);
      final elapsed = _activeElapsed(now);
      state = state.copyWith(
        elapsed: elapsed,
        pacePerKilometer: RunMetrics.paceFor(
          state.distanceKilometers,
          _movingElapsed,
        ),
        clearPace: state.distanceKilometers <= 0,
        calories: _caloriesExact.round(),
      );
      unawaited(_persistRecovery());
    });
  }

  void _advanceMetrics(DateTime now) {
    final previous = _lastMetricAt;
    if (previous == null || !now.isAfter(previous)) return;
    final interval = now.difference(previous);
    if (state.stage.contributesToRunMetrics) {
      _movingElapsed += interval;
      _caloriesExact += RunMetrics.caloriesExactFor(state.stage, interval);
    }
    _lastMetricAt = now;
  }

  Duration _activeElapsed(DateTime now) {
    final segmentStart = _segmentStartedAt;
    if (segmentStart == null || !now.isAfter(segmentStart)) {
      return _completedActiveTime;
    }
    return _completedActiveTime + now.difference(segmentStart);
  }

  void _closeActiveSegment(DateTime now) {
    _advanceMetrics(now);
    _completedActiveTime = _activeElapsed(now);
    _segmentStartedAt = null;
    _lastMetricAt = null;
    state = state.copyWith(
      elapsed: _completedActiveTime,
      calories: _caloriesExact.round(),
    );
  }

  Future<void> _persistRecovery({bool force = false}) async {
    if (!state.hasStarted || state.startedAt == null) return;
    final now = _now;
    if (!force &&
        _lastRecoveryWriteAt != null &&
        now.difference(_lastRecoveryWriteAt!) < _recoveryWriteInterval) {
      return;
    }
    _lastRecoveryWriteAt = now;
    try {
      await _sessionRepository.saveActiveSession(
        RunSessionSnapshot(
          startedAt: state.startedAt!,
          elapsed: state.elapsed,
          movingElapsed: _movingElapsed,
          distanceKilometers: state.distanceKilometers,
          caloriesExact: _caloriesExact,
          steps: state.steps,
          stage: state.stage,
        ),
      );
    } catch (error, stackTrace) {
      logger.e(
        'Failed to save run recovery point',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _stopSensors({RunSensorService? sensorService}) async {
    _ticker?.cancel();
    _ticker = null;
    try {
      await _sensorSubscription?.cancel();
    } catch (error, stackTrace) {
      logger.e(
        'Unable to detach the run sensor listener',
        error: error,
        stackTrace: stackTrace,
      );
    }
    _sensorSubscription = null;
    try {
      await (sensorService ?? _sensor).stop();
    } catch (error, stackTrace) {
      logger.e(
        'Unable to stop run sensors cleanly',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
