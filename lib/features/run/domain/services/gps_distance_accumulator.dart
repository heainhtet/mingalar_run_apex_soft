import 'dart:math' as math;

import '../entities/run_sensor_frame.dart';

/// Accumulates credible GPS movement while rejecting stationary drift and
/// physically implausible jumps.
class GpsDistanceAccumulator {
  GpsDistanceAccumulator({this.maximumSpeedMetersPerSecond = 12.5});

  final double maximumSpeedMetersPerSecond;

  RunSensorFrame? _lastLocationFrame;
  double _distanceKilometers = 0;

  double get distanceKilometers => _distanceKilometers;

  void reset({double initialDistanceKilometers = 0}) {
    _lastLocationFrame = null;
    _distanceKilometers = initialDistanceKilometers.isFinite
        ? math.max(0, initialDistanceKilometers)
        : 0;
  }

  double add(RunSensorFrame frame) {
    if (!frame.isLocationUpdate || !frame.isUsable) {
      return _distanceKilometers;
    }

    final previous = _lastLocationFrame;
    _lastLocationFrame = frame;
    if (previous == null) return _distanceKilometers;

    final meters = _distanceBetween(
      previous.latitude,
      previous.longitude,
      frame.latitude,
      frame.longitude,
    );
    if (_isPlausibleMovement(previous, frame, meters)) {
      _distanceKilometers += meters / 1000;
    }
    return _distanceKilometers;
  }

  bool _isPlausibleMovement(
    RunSensorFrame previous,
    RunSensorFrame current,
    double meters,
  ) {
    if (!meters.isFinite || meters <= 0) return false;

    // GPS validates a route only after the native motion pipeline has
    // confirmed walking. GPS speed is not activity evidence: it can drift
    // while the phone is sitting still.
    if (current.pedestrianStatus != PedestrianState.walking) {
      return false;
    }

    final noiseFloor = math.max(
      2.5,
      math.min(8, (previous.accuracyMeters + current.accuracyMeters) * 0.15),
    );
    if (meters < noiseFloor) return false;

    final previousAt = previous.recordedAt;
    final currentAt = current.recordedAt;
    if (previousAt == null || currentAt == null) return meters < 40;

    final seconds =
        currentAt.difference(previousAt).inMicroseconds /
        Duration.microsecondsPerSecond;
    if (seconds <= 0) return false;
    return meters / seconds <= maximumSpeedMetersPerSecond;
  }

  static double _distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const earthRadiusMeters = 6371000.0;
    final latitudeDelta = _radians(endLatitude - startLatitude);
    final longitudeDelta = _radians(endLongitude - startLongitude);
    final startLatitudeRadians = _radians(startLatitude);
    final endLatitudeRadians = _radians(endLatitude);

    final haversine =
        math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
        math.cos(startLatitudeRadians) *
            math.cos(endLatitudeRadians) *
            math.sin(longitudeDelta / 2) *
            math.sin(longitudeDelta / 2);
    return earthRadiusMeters *
        2 *
        math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));
  }

  static double _radians(double degrees) => degrees * math.pi / 180;
}
