import '../entities/run_sensor_frame.dart';

enum RunPermissionResult {
  granted,
  locationServiceDisabled,
  locationPermissionDenied,
  locationPermissionPermanentlyDenied,
  motionPermissionDenied,
  motionPermissionPermanentlyDenied,
  failed,
}

abstract interface class RunSensorService {
  Future<RunPermissionResult> requestPermission();

  Future<bool> openLocationSettings();

  Future<bool> openAppSettings();

  Stream<RunSensorFrame> start();

  Future<void> stop();
}
