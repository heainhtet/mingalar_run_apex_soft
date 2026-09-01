import 'dart:async';
import 'dart:math' as math;

import 'package:cm_pedometer/cm_pedometer.dart' as cm_pedometer;
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart' as android_pedometer;
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/utils/app_platform.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/run_sensor_frame.dart';
import '../../domain/services/run_sensor_service.dart';

class GeolocatorRunSensorService implements RunSensorService {
  StreamSubscription<Position>? _gpsSubscription;
  StreamSubscription<cm_pedometer.CMPedometerData>? _iosDataSubscription;
  StreamSubscription<cm_pedometer.CMPedestrianStatus>? _iosStatusSubscription;
  StreamSubscription<android_pedometer.StepCount>? _androidStepSubscription;
  StreamSubscription<android_pedometer.PedestrianStatus>?
  _androidStatusSubscription;
  StreamController<RunSensorFrame>? _controller;

  bool _hasPosition = false;
  double _speed = 0;
  double _latitude = 0;
  double _longitude = 0;
  double _accuracy = 0;

  int _stepCounterBaseline = 0;
  int _sessionSteps = 0;
  bool _receivedAndroidStepCounter = false;
  bool _hasStepData = false;
  StepDataSource _stepSource = StepDataSource.unavailable;
  PedestrianState _pedestrian = PedestrianState.stopped;
  double _cadence = 0;
  double? _nativeDistanceKilometers;
  Duration? _nativePacePerKilometer;

  @override
  Future<RunPermissionResult> requestPermission() async {
    try {
      if (AppPlatform.isIOS) {
        logger.i('iOS Core Motion permission will be requested by CMPedometer');
        return RunPermissionResult.granted;
      }

      final locationResult = await _requestAndroidLocationPermission();
      if (locationResult != RunPermissionResult.granted) {
        return locationResult;
      }

      final motion = await Permission.activityRecognition.request();
      if (!motion.isGranted) {
        logger.i('Run start blocked: motion permission=${motion.name}');
        return motion.isPermanentlyDenied
            ? RunPermissionResult.motionPermissionPermanentlyDenied
            : RunPermissionResult.motionPermissionDenied;
      }

      final notification = await Permission.notification.request();
      logger.i('Run notification permission=${notification.name}');
      logger.i('Android run permissions granted');
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

  Future<RunPermissionResult> _requestAndroidLocationPermission() async {
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
    return RunPermissionResult.granted;
  }

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  @override
  Stream<RunSensorFrame> start() {
    if (_controller != null ||
        _gpsSubscription != null ||
        _iosDataSubscription != null ||
        _iosStatusSubscription != null ||
        _androidStepSubscription != null ||
        _androidStatusSubscription != null) {
      throw StateError('Run sensors must be stopped before restarting.');
    }

    _resetSessionSensors();
    _controller = StreamController<RunSensorFrame>.broadcast();
    if (AppPlatform.isIOS) {
      _startIosMotionStreams();
    } else {
      _startAndroidTrackingStreams();
    }
    return _controller!.stream;
  }

  void _startIosMotionStreams() {
    final startedAt = DateTime.now();
    _iosDataSubscription =
        cm_pedometer.CMPedometer.stepCounterFirstStream(from: startedAt).listen(
          _onIosPedometerData,
          onError: (Object error, StackTrace stackTrace) =>
              _onStepDataError('iOS Core Motion data', error, stackTrace),
        );
    _iosStatusSubscription = cm_pedometer.CMPedometer.pedestrianStatusStream
        .listen(
          _onIosPedestrianStatus,
          onError: (Object error, StackTrace stackTrace) =>
              _onStatusError('iOS Core Motion status', error, stackTrace),
        );
  }

  void _startAndroidTrackingStreams() {
    _androidStepSubscription = android_pedometer.Pedometer.stepCountStream
        .listen(
          _onAndroidStepCount,
          onError: (Object error, StackTrace stackTrace) => _onStepDataError(
            'Android pedometer step count',
            error,
            stackTrace,
          ),
        );
    _androidStatusSubscription = android_pedometer
        .Pedometer
        .pedestrianStatusStream
        .listen(
          _onAndroidPedestrianStatus,
          onError: (Object error, StackTrace stackTrace) =>
              _onStatusError('Android pedometer status', error, stackTrace),
        );

    final settings = AndroidSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 3,
      intervalDuration: Duration(seconds: 2),
      foregroundNotificationConfig: ForegroundNotificationConfig(
        notificationTitle: 'Mingalar Run is tracking your run',
        notificationText: 'Distance, pace and steps are being recorded.',
        notificationChannelName: 'Active run tracking',
        enableWakeLock: true,
        setOngoing: true,
      ),
    );
    _gpsSubscription = Geolocator.getPositionStream(locationSettings: settings)
        .listen(
          _onPosition,
          onError: (Object error, StackTrace stackTrace) =>
              _fail('GPS', error, stackTrace),
        );
  }

  void _resetSessionSensors() {
    _hasPosition = false;
    _speed = 0;
    _latitude = 0;
    _longitude = 0;
    _accuracy = 0;
    _stepCounterBaseline = 0;
    _sessionSteps = 0;
    _receivedAndroidStepCounter = false;
    _hasStepData = false;
    _stepSource = StepDataSource.unavailable;
    _pedestrian = PedestrianState.stopped;
    _cadence = 0;
    _nativeDistanceKilometers = null;
    _nativePacePerKilometer = null;
  }

  void _onIosPedometerData(cm_pedometer.CMPedometerData data) {
    _sessionSteps = math.max(_sessionSteps, math.max(0, data.numberOfSteps));
    _hasStepData = true;
    _stepSource = StepDataSource.cmPedometer;
    _nativeDistanceKilometers = _kilometersFromMeters(data.distance);
    _nativePacePerKilometer = _pacePerKilometer(data.averageActivePace);
    _cadence = _cadencePerMinute(data.currentCadence);
    _emit(recordedAt: data.timeStamp);
  }

  void _onIosPedestrianStatus(cm_pedometer.CMPedestrianStatus status) {
    _pedestrian = _pedestrianState(status.status);
    _emit(recordedAt: status.timeStamp);
  }

  void _onAndroidStepCount(android_pedometer.StepCount event) {
    final reportedSteps = event.steps;
    if (reportedSteps < 0) return;

    if (!_receivedAndroidStepCounter) {
      _receivedAndroidStepCounter = true;
      _stepCounterBaseline = reportedSteps;
      _hasStepData = true;
      _stepSource = StepDataSource.androidPedometer;
      _emit(recordedAt: event.timeStamp);
      return;
    }

    final sessionSteps = reportedSteps - _stepCounterBaseline;
    if (sessionSteps < _sessionSteps) {
      _stepCounterBaseline = reportedSteps;
      return;
    }
    _sessionSteps = sessionSteps;
    _hasStepData = true;
    _stepSource = StepDataSource.androidPedometer;
    _emit(recordedAt: event.timeStamp);
  }

  void _onAndroidPedestrianStatus(android_pedometer.PedestrianStatus status) {
    _pedestrian = _pedestrianState(status.status);
    _emit(recordedAt: status.timeStamp);
  }

  void _onPosition(Position position) {
    _hasPosition = true;
    _speed = position.speed.isFinite && position.speed > 0 ? position.speed : 0;
    _latitude = position.latitude;
    _longitude = position.longitude;
    _accuracy = position.accuracy;
    _emit(isLocationUpdate: true, recordedAt: position.timestamp);
  }

  PedestrianState _pedestrianState(String status) => switch (status) {
    'walking' => PedestrianState.walking,
    'stopped' => PedestrianState.stopped,
    _ => PedestrianState.unknown,
  };

  double? _kilometersFromMeters(double? meters) {
    if (meters == null || !meters.isFinite || meters < 0) return null;
    return meters / 1000;
  }

  Duration? _pacePerKilometer(double? secondsPerMeter) {
    if (secondsPerMeter == null ||
        !secondsPerMeter.isFinite ||
        secondsPerMeter <= 0) {
      return null;
    }
    return Duration(milliseconds: (secondsPerMeter * 1000000).round());
  }

  double _cadencePerMinute(double? stepsPerSecond) {
    if (stepsPerSecond == null ||
        !stepsPerSecond.isFinite ||
        stepsPerSecond <= 0) {
      return 0;
    }
    return stepsPerSecond * 60;
  }

  void _onStepDataError(String source, Object error, [StackTrace? stackTrace]) {
    logger.e('$source is unavailable', error: error, stackTrace: stackTrace);
    _hasStepData = false;
    _stepSource = StepDataSource.unavailable;
    _emit(recordedAt: DateTime.now());
  }

  void _onStatusError(String source, Object error, [StackTrace? stackTrace]) {
    logger.e('$source is unavailable', error: error, stackTrace: stackTrace);
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
        nativeDistanceKilometers: _nativeDistanceKilometers,
        nativePacePerKilometer: _nativePacePerKilometer,
        usesNativePedometerMetrics: AppPlatform.isIOS,
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
    await Future.wait([
      _cancelSafely(_gpsSubscription, 'GPS stream'),
      _cancelSafely(_iosDataSubscription, 'iOS Core Motion data'),
      _cancelSafely(_iosStatusSubscription, 'iOS Core Motion status'),
      _cancelSafely(_androidStepSubscription, 'Android pedometer steps'),
      _cancelSafely(_androidStatusSubscription, 'Android pedometer status'),
    ]);
    _gpsSubscription = null;
    _iosDataSubscription = null;
    _iosStatusSubscription = null;
    _androidStepSubscription = null;
    _androidStatusSubscription = null;
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
