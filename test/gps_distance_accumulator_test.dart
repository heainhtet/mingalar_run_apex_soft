import 'package:flutter_test/flutter_test.dart';
import 'package:mingalar_un/features/run/domain/entities/run_sensor_frame.dart';
import 'package:mingalar_un/features/run/domain/services/gps_distance_accumulator.dart';

void main() {
  const latitude = 16.8388;
  const longitude = 96.144;
  final start = DateTime(2026, 8, 31, 6);

  RunSensorFrame frame({
    required double latitude,
    required double longitude,
    required DateTime at,
    double speed = 0,
    double accuracy = 5,
    double cadence = 0,
    PedestrianState pedestrian = PedestrianState.unknown,
  }) {
    return RunSensorFrame(
      latitude: latitude,
      longitude: longitude,
      speedMetersPerSecond: speed,
      accuracyMeters: accuracy,
      cadenceStepsPerMinute: cadence,
      pedestrianStatus: pedestrian,
      recordedAt: at,
    );
  }

  test('accepts plausible GPS movement during confirmed motion', () {
    final tracker = GpsDistanceAccumulator();
    tracker.add(
      frame(
        latitude: latitude,
        longitude: longitude,
        at: start,
        pedestrian: PedestrianState.walking,
      ),
    );

    final distance = tracker.add(
      frame(
        latitude: latitude + 0.0001,
        longitude: longitude,
        at: start.add(const Duration(seconds: 8)),
        pedestrian: PedestrianState.walking,
      ),
    );

    expect(distance, greaterThan(0.01));
    expect(distance, lessThan(0.02));
  });

  test('rejects coordinate drift without motion evidence', () {
    final tracker = GpsDistanceAccumulator();
    tracker.add(frame(latitude: latitude, longitude: longitude, at: start));

    final distance = tracker.add(
      frame(
        latitude: latitude + 0.0001,
        longitude: longitude,
        at: start.add(const Duration(seconds: 8)),
      ),
    );

    expect(distance, 0);
  });

  test('explicit stopped status overrides reported GPS movement', () {
    final tracker = GpsDistanceAccumulator();
    tracker.add(
      frame(latitude: latitude, longitude: longitude, at: start, speed: 1.4),
    );

    final distance = tracker.add(
      frame(
        latitude: latitude + 0.0001,
        longitude: longitude,
        at: start.add(const Duration(seconds: 8)),
        speed: 1.4,
        pedestrian: PedestrianState.stopped,
      ),
    );

    expect(distance, 0);
  });

  test('rejects inaccurate points and resets cleanly', () {
    final tracker = GpsDistanceAccumulator();
    tracker.add(
      frame(latitude: latitude, longitude: longitude, at: start, accuracy: 50),
    );
    tracker.add(
      frame(
        latitude: latitude + 0.0001,
        longitude: longitude,
        at: start.add(const Duration(seconds: 8)),
        speed: 1.4,
        accuracy: 50,
      ),
    );
    expect(tracker.distanceKilometers, 0);

    tracker.reset(initialDistanceKilometers: 1.25);
    expect(tracker.distanceKilometers, 1.25);
  });
}
