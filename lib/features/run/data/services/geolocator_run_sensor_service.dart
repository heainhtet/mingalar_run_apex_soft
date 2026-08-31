import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/entities/run_sensor_frame.dart';
import '../../domain/services/run_sensor_service.dart';

/// Converts native location and pedometer streams into normalized run frames.
class GeolocatorRunSensorService implements RunSensorService {
  static const _inactivityTimeout = Duration(seconds: 3);
  static const _pendingStepWindow = Duration(seconds: 2);

  StreamSubscription<Position>? _gpsSubscription;
  StreamSubscription<StepCount>? _stepSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianSubscription;
  StreamController<RunSensorFrame>? _controller;
  Timer? _inactivityTimer;

  bool _hasPosition = false;
  double _speed = 0;
  double _latitude = 0;
  double _longitude = 0;
  double _accuracy = 0;

  int _lastRawSteps = 0;
  int _sessionSteps = 0;
  bool _firstStepEvent = true;
  bool _hasStepData = false;
  StepDataSource _stepSource = StepDataSource.unavailable;
  int _pendingNativeSteps = 0;
  DateTime? _pendingNativeStepsAt;
  DateTime? _lastStepAt;
  double _cadence = 0;
  PedestrianState _pedestrian = PedestrianState.unknown;
  DateTime? _lastMotionAt;
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

      if (Platform.isAndroid) {
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
        _stepSubscription != null ||
        _pedestrianSubscription != null ||
        _inactivityTimer != null) {
      throw StateError('Run sensors must be stopped before restarting.');
    }

    _controller = StreamController<RunSensorFrame>.broadcast();
    _hasPosition = false;
    _sessionSteps = 0;
    _lastRawSteps = 0;
    _firstStepEvent = true;
    _hasStepData = false;
    _stepSource = StepDataSource.unavailable;
    _pendingNativeSteps = 0;
    _pendingNativeStepsAt = null;
    _cadence = 0;
    _pedestrian = PedestrianState.unknown;
    _lastStepAt = null;
    _lastMotionAt = null;
    _inactivityTimer = Timer.periodic(
      const Duration(seconds: 1),
      _checkForInactivity,
    );

    final settings = Platform.isAndroid
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
      _listenPedometer();
    } else {
      logger.i(
        'Native motion permission unavailable; step and activity data disabled',
      );
    }

    return _controller!.stream;
  }

  void _listenPedometer() {
    try {
      _stepSubscription = Pedometer.stepCountStream.listen(
        _onSteps,
        onError: _onStepSensorError,
      );
      _pedestrianSubscription = Pedometer.pedestrianStatusStream.listen(
        _onPedestrian,
        onError: _onPedestrianSensorError,
      );
    } catch (error, stackTrace) {
      logger.e(
        'Native pedometer is unavailable; step and activity data disabled',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _onPosition(Position position) {
    _hasPosition = true;
    _speed = position.speed.isFinite && position.speed > 0 ? position.speed : 0;
    _latitude = position.latitude;
    _longitude = position.longitude;
    _accuracy = position.accuracy;
    _emit(isLocationUpdate: true);
  }

  void _onSteps(StepCount event) {
    if (_firstStepEvent) {
      _lastRawSteps = event.steps;
      _firstStepEvent = false;
      _hasStepData = true;
      _stepSource = StepDataSource.nativePedometer;
      _emit();
      return;
    }

    final now = DateTime.now();
    final delta = event.steps - _lastRawSteps;
    _lastRawSteps = event.steps;

    // A step event alone is not proof of walking. Some devices increment their
    // counter when shaken, so explicit native stopped status rejects the delta.
    if (delta > 0 && delta < 1000) {
      switch (_pedestrian) {
        case PedestrianState.walking:
          _recordNativeSteps(delta, now);
        case PedestrianState.unknown:
          _pendingNativeSteps += delta;
          _pendingNativeStepsAt = now;
        case PedestrianState.stopped:
          logger.d('Ignored $delta native step(s) while status was stopped');
      }
    }
    _emit();
  }

  void _onPedestrian(PedestrianStatus event) {
    _pedestrian = switch (event.status) {
      'walking' => PedestrianState.walking,
      'stopped' => PedestrianState.stopped,
      _ => PedestrianState.unknown,
    };
    if (_pedestrian == PedestrianState.stopped) {
      _clearPendingNativeSteps();
      _cadence = 0;
    } else if (_pedestrian == PedestrianState.walking) {
      final now = DateTime.now();
      final pendingAt = _pendingNativeStepsAt;
      if (_pendingNativeSteps > 0 &&
          pendingAt != null &&
          now.difference(pendingAt) <= _pendingStepWindow) {
        _recordNativeSteps(_pendingNativeSteps, now);
      }
      _clearPendingNativeSteps();
      _lastMotionAt = now;
      if (_isInactiveAt(now)) {
        _pedestrian = PedestrianState.stopped;
        _cadence = 0;
      }
    }
    _emit();
  }

  void _onStepSensorError(Object error) {
    logger.e('Native step stream failed; step data disabled', error: error);
    unawaited(_cancelSafely(_stepSubscription, 'native step stream'));
    _stepSubscription = null;
    _stepSource = StepDataSource.unavailable;
    _hasStepData = false;
    _clearPendingNativeSteps();
    _emit();
  }

  void _onPedestrianSensorError(Object error) {
    _pedestrian = PedestrianState.unknown;
    logger.e('Pedestrian status is unavailable', error: error);
  }

  void _recordNativeSteps(int delta, DateTime recordedAt) {
    _sessionSteps += delta;
    _lastMotionAt = recordedAt;
    final previousStepAt = _lastStepAt;
    if (previousStepAt != null) {
      final minutes =
          recordedAt.difference(previousStepAt).inMilliseconds / 60000.0;
      if (minutes > 0) {
        _cadence = (delta / minutes).clamp(0, 220).toDouble();
      }
    }
    _lastStepAt = recordedAt;
  }

  void _clearPendingNativeSteps() {
    _pendingNativeSteps = 0;
    _pendingNativeStepsAt = null;
  }

  void _checkForInactivity(Timer timer) {
    final now = DateTime.now();
    final pendingAt = _pendingNativeStepsAt;
    if (pendingAt != null && now.difference(pendingAt) > _pendingStepWindow) {
      _clearPendingNativeSteps();
    }
    if (_isInactiveAt(now)) _markStopped();
  }

  bool _isInactiveAt(DateTime now) {
    final lastMotion = _lastMotionAt;
    return lastMotion != null &&
        now.difference(lastMotion) >= _inactivityTimeout;
  }

  void _markStopped() {
    if (_pedestrian == PedestrianState.stopped &&
        _cadence == 0 &&
        _speed == 0) {
      return;
    }
    _pedestrian = PedestrianState.stopped;
    _cadence = 0;
    _speed = 0;
    _emit();
    logger.d('No movement detected for 3s; activity changed to stopped');
  }

  void _emit({bool isLocationUpdate = false}) {
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
        recordedAt: DateTime.now(),
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

  Future<void> _cancelSubscriptions() async {
    await Future.wait([
      _cancelSafely(_gpsSubscription, 'GPS stream'),
      _cancelSafely(_stepSubscription, 'native step stream'),
      _cancelSafely(_pedestrianSubscription, 'pedestrian status stream'),
    ]);
    _gpsSubscription = null;
    _stepSubscription = null;
    _pedestrianSubscription = null;
  }

  Future<void> _cancelSafely(
    StreamSubscription<dynamic>? subscription,
    String source,
  ) async {
    if (subscription == null) return;
    try {
      await subscription.cancel();
    } catch (error) {
      // Some plugin streams fail before activation, then throw again on cancel.
      // Cleanup is idempotent because every subscription is cleared afterward.
      logger.d('$source was already inactive during cleanup: $error');
    }
  }

  @override
  Future<void> stop() async {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    await _cancelSubscriptions();
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
