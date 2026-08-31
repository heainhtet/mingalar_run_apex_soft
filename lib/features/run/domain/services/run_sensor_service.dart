import '../entities/run_sensor_frame.dart';

enum RunPermissionResult {
  granted,
  locationServiceDisabled,
  locationPermissionDenied,
  locationPermissionPermanentlyDenied,
  failed,
}

/// Supplies normalized location and motion readings to a run session.
///
/// Platform plugin types stay behind this interface so session calculations can
/// be tested with deterministic sensor frames.
abstract interface class RunSensorService {
  /// Checks location services and requests the permissions needed for a run.
  Future<RunPermissionResult> requestPermission();

  Future<bool> openLocationSettings();

  Future<bool> openAppSettings();

  /// Starts streaming sensor frames. Must be called after permission is granted.
  ///
  /// The returned stream is a broadcast stream; the caller is responsible for
  /// cancelling the subscription and calling [stop] when finished.
  Stream<RunSensorFrame> start();

  /// Stops the underlying sensor stream and releases platform resources.
  Future<void> stop();
}
