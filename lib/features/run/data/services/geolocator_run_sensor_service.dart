import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/utils/app_platform.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/run_sensor_frame.dart';
import '../../domain/services/run_motion_classifier.dart';
import '../../domain/services/run_sensor_service.dart';
import 'native_motion_tracker.dart';

/// Combines GPS distance readings with one native motion stream.
///
/// The native adapter owns all step and activity inputs. GPS is intentionally
/// kept out of motion classification so location drift can never report a walk,
/// jog, or run.
class GeolocatorRunSensorService implements RunSensorService {
  GeolocatorRunSensorService({
    NativeMotionTracker? motionTracker,
    RunMotionClassifier? motionClassifier,
  }) : _motionTracker = motionTracker ?? PlatformNativeMotionTracker(),
       _motionClassifier = motionClassifier ?? RunMotionClassifier();

  final NativeMotionTracker _motionTracker;
  final RunMotionClassifier _motionClassifier;

  StreamSubscription<Position>? _gpsSubscription;
  StreamSubscription<NativeMotionEvent>? _motionSubscription;
  StreamController<RunSensorFrame>? _controller;
  Timer? _motionRefreshTimer;

  bool _hasPosition = false;
  double _speed = 0;
  double _latitude = 0;
  double _longitude = 0;
  double _accuracy = 0;

  int _stepCounterBaseline = 0;
  int _sessionSteps = 0;
  bool _firstStepCounterEvent = true;
  bool _hasStepData = false;
  StepDataSource _stepSource = StepDataSource.unavailable;
  PedestrianState _pedestrian = PedestrianState.stopped;
  double _cadence = 0;
  bool _motionPermissionGranted = false;

  @override
  Future<RunPermissionResult> requestPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        logger.i('Run start blocked: location service is disabled');
        return RunPermissionResult.locationServiceDisabled;
      }

      var location = await Geolocator.checkPermission();
      if (location == LocationPermission.denied) {
        location = await Geolocator.requestPermission();
      }
      if (location == LocationPermission.deniedForever) {
        logger.i('Run start blocked: location permission permanently denied');
        return RunPermissionResult.locationPermissionPermanentlyDenied;
      }
      if (location != LocationPermission.always &&
          location != LocationPermission.whileInUse) {
        logger.i('Run start blocked: location permission denied');
        return RunPermissionResult.locationPermissionDenied;
      }

      final motion = await Permission.activityRecognition.request();
      _motionPermissionGranted = motion.isGranted;
      logger.i('Run permissions: location=$location, motion=${motion.name}');

      if (AppPlatform.isAndroid) {
        final notification = await Permission.notification.request();
        logger.i('Run notification permission=${notification.name}');
      }
      return RunPermissionResult.granted;
    } catch (error, stackTrace) {
      logger.e(
        'Unable to request run permissions',
        error: error,
        stackTrace: stackTrace,
      );
      return RunPermissionResult.failed;
    }
  }

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  @override
  Stream<RunSensorFrame> start() {
    if (_controller != null ||
        _gpsSubscription != null ||
        _motionSubscription != null ||
        _motionRefreshTimer != null) {
      throw StateError('Run sensors must be stopped before restarting.');
    }

    _resetSessionSensors();
    _controller = StreamController<RunSensorFrame>.broadcast();
    _motionRefreshTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _refreshMotion(DateTime.now()),
    );

    final settings = AppPlatform.isAndroid
        ? AndroidSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 3,
            intervalDuration: const Duration(seconds: 2),
            foregroundNotificationConfig: const ForegroundNotificationConfig(
              notificationTitle: 'Mingalar Run is tracking your run',
              notificationText: 'Distance, pace and steps are being recorded.',
              notificationChannelName: 'Active run tracking',
              enableWakeLock: true,
              setOngoing: true,
            ),
          )
        : AppleSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            activityType: ActivityType.fitness,
            distanceFilter: 3,
            pauseLocationUpdatesAutomatically: false,
            showBackgroundLocationIndicator: true,
          );
    _gpsSubscription = Geolocator.getPositionStream(locationSettings: settings)
        .listen(
          _onPosition,
          onError: (Object error, StackTrace stackTrace) =>
              _fail('GPS', error, stackTrace),
        );

    if (_motionPermissionGranted) {
      _motionSubscription = _motionTracker.events.listen(
        _onNativeMotionEvent,
        onError: _onNativeMotionError,
      );
    } else {
      logger.i(
        'Native motion permission unavailable; steps and activity are disabled',
      );
    }

    return _controller!.stream;
  }

  void _resetSessionSensors() {
    _hasPosition = false;
    _speed = 0;
    _latitude = 0;
    _longitude = 0;
    _accuracy = 0;
    _stepCounterBaseline = 0;
    _sessionSteps = 0;
    _firstStepCounterEvent = true;
    _hasStepData = false;
    _stepSource = StepDataSource.unavailable;
    _pedestrian = PedestrianState.stopped;
    _cadence = 0;
    _motionClassifier.reset();
  }

  void _onPosition(Position position) {
    _hasPosition = true;
    _speed = position.speed.isFinite && position.speed > 0 ? position.speed : 0;
    _latitude = position.latitude;
    _longitude = position.longitude;
    _accuracy = position.accuracy;
    _refreshMotion(DateTime.now(), isLocationUpdate: true);
  }

  void _onNativeMotionEvent(NativeMotionEvent event) {
    switch (event.type) {
      case NativeMotionEventType.stepCounter:
        _recordStepCounter(event);
      case NativeMotionEventType.stepDetector:
        _motionClassifier.recordStepDetector(event.recordedAt);
      case NativeMotionEventType.cadence:
        _motionClassifier.updateCadence(event.cadenceStepsPerMinute);
      case NativeMotionEventType.activity:
        _motionClassifier.updateActivity(
          activity: event.activity,
          confidence: event.confidence,
          recordedAt: event.recordedAt,
        );
      case NativeMotionEventType.availability:
        if (!event.isAvailable) {
          logger.i('Native motion capability is unavailable on this device');
        }
    }
    _refreshMotion(event.recordedAt);
  }

  void _recordStepCounter(NativeMotionEvent event) {
    final reportedSteps = event.steps;
    if (reportedSteps < 0) return;

    if (_firstStepCounterEvent) {
      _firstStepCounterEvent = false;
      _hasStepData = true;
      _stepSource = StepDataSource.nativeMotion;
      _stepCounterBaseline = reportedSteps;
      _sessionSteps = event.isSessionTotal ? reportedSteps : 0;
      if (event.isSessionTotal && reportedSteps > 0) {
        // CMPedometer reports steps since this session started. Its first
        // delivery can already contain several genuine steps, so retain that
        // hardware count for the iOS confirmation window.
        _motionClassifier.recordPedometerDelta(
          stepDelta: reportedSteps,
          recordedAt: event.recordedAt,
          cadenceStepsPerMinute: event.cadenceStepsPerMinute,
        );
      }
      return;
    }

    final nextSessionSteps = event.isSessionTotal
        ? reportedSteps
        : reportedSteps - _stepCounterBaseline;
    if (nextSessionSteps < _sessionSteps) {
      // Android counters reset only after a device restart. Re-baselining keeps
      // a current session monotonic instead of turning a reset into fake steps.
      _stepCounterBaseline = reportedSteps;
      return;
    }

    final delta = nextSessionSteps - _sessionSteps;
    _sessionSteps = nextSessionSteps;
    _hasStepData = true;
    _stepSource = StepDataSource.nativeMotion;
    if (delta > 0) {
      _motionClassifier.recordPedometerDelta(
        stepDelta: delta,
        recordedAt: event.recordedAt,
        cadenceStepsPerMinute: event.cadenceStepsPerMinute,
      );
    }
  }

  void _refreshMotion(DateTime now, {bool isLocationUpdate = false}) {
    final classification = _motionClassifier.classify(now);
    _pedestrian = classification.pedestrianState;
    _cadence = classification.cadenceStepsPerMinute;
    _emit(isLocationUpdate: isLocationUpdate, recordedAt: now);
  }

  void _onNativeMotionError(Object error, [StackTrace? stackTrace]) {
    logger.e(
      'Native motion stream failed; step and activity data are unavailable',
      error: error,
      stackTrace: stackTrace,
    );
    _hasStepData = false;
    _stepSource = StepDataSource.unavailable;
    _pedestrian = PedestrianState.stopped;
    _cadence = 0;
    _emit(recordedAt: DateTime.now());
  }

  void _emit({bool isLocationUpdate = false, DateTime? recordedAt}) {
    _controller?.add(
      RunSensorFrame(
        latitude: _latitude,
        longitude: _longitude,
        speedMetersPerSecond: _speed,
        accuracyMeters: _accuracy,
        steps: _sessionSteps,
        cadenceStepsPerMinute: _cadence,
        pedestrianStatus: _pedestrian,
        stepSource: _stepSource,
        recordedAt: recordedAt ?? DateTime.now(),
        hasStepData: _hasStepData,
        hasLocationData: _hasPosition,
        isLocationUpdate: isLocationUpdate,
      ),
    );
  }

  void _fail(String source, Object error, StackTrace stackTrace) {
    logger.e(
      '$source sensor stream failed',
      error: error,
      stackTrace: stackTrace,
    );
    _controller?.addError(
      RunSensorException('$source stream encountered an error.'),
    );
  }

  Future<void> _cancelSafely(
    StreamSubscription<dynamic>? subscription,
    String source,
  ) async {
    if (subscription == null) return;
    try {
      await subscription.cancel();
    } catch (error) {
      logger.d('$source was already inactive during cleanup: $error');
    }
  }

  @override
  Future<void> stop() async {
    _motionRefreshTimer?.cancel();
    _motionRefreshTimer = null;
    await Future.wait([
      _cancelSafely(_gpsSubscription, 'GPS stream'),
      _cancelSafely(_motionSubscription, 'native motion stream'),
    ]);
    _gpsSubscription = null;
    _motionSubscription = null;
    await _controller?.close();
    _controller = null;
    logger.i('Run sensors stopped');
  }
}

class RunSensorException implements Exception {
  const RunSensorException(this.message);

  final String message;

  @override
  String toString() => message;
}
