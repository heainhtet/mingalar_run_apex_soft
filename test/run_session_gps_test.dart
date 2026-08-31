import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mingalar_un/features/run/domain/entities/run_sensor_frame.dart';
import 'package:mingalar_un/features/run/domain/entities/run_session_snapshot.dart';
import 'package:mingalar_un/features/run/domain/services/run_sensor_service.dart';
import 'package:mingalar_un/features/run/presentation/providers/run_providers.dart';
import 'package:mingalar_un/features/run/presentation/providers/run_session_provider.dart';

import 'support/in_memory_repositories.dart';

class FakeRunSensorService implements RunSensorService {
  final StreamController<RunSensorFrame> _controller =
      StreamController<RunSensorFrame>.broadcast();

  RunPermissionResult permissionResult = RunPermissionResult.granted;
  bool started = false;
  bool stopped = false;

  @override
  Future<RunPermissionResult> requestPermission() async => permissionResult;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;

  @override
  Stream<RunSensorFrame> start() {
    started = true;
    stopped = false;
    return _controller.stream;
  }

  @override
  Future<void> stop() async {
    started = false;
    stopped = true;
  }

  void emit(RunSensorFrame frame) => _controller.add(frame);
}

class MutableClock {
  MutableClock(this.value);
  DateTime value;
  DateTime call() => value;
  void advance(Duration duration) => value = value.add(duration);
}

void main() {
  group('RunStage.classify', () {
    test('requires native walking status before classifying cadence', () {
      expect(
        RunStage.classify(pedestrianWalking: false, cadence: 220),
        RunStage.stopped,
      );
      expect(RunStage.classify(pedestrianWalking: true), RunStage.walking);
      expect(
        RunStage.classify(pedestrianWalking: true, cadence: 129),
        RunStage.walking,
      );
      expect(
        RunStage.classify(pedestrianWalking: true, cadence: 130),
        RunStage.jogging,
      );
      expect(
        RunStage.classify(pedestrianWalking: true, cadence: 160),
        RunStage.running,
      );
    });

    test('stopped time does not add active calories', () {
      expect(
        RunMetrics.caloriesFor(RunStage.stopped, const Duration(hours: 2)),
        0,
      );
    });
  });

  group('RunSessionNotifier GPS', () {
    test('starts running after permission is granted', () async {
      final sensor = FakeRunSensorService();
      final container = ProviderContainer(
        overrides: [
          runActivityRepositoryProvider.overrideWithValue(
            InMemoryRunActivityRepository(),
          ),
          runSensorServiceProvider.overrideWithValue(sensor),
          runSessionRepositoryProvider.overrideWithValue(
            InMemoryRunSessionRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(runSessionProvider.notifier);
      final started = await notifier.start();

      expect(started, RunPermissionResult.granted);
      expect(sensor.started, isTrue);
      expect(
        container.read(runSessionProvider).status,
        RunSessionStatus.running,
      );
    });

    test('stays idle when permission is denied', () async {
      final sensor = FakeRunSensorService()
        ..permissionResult = RunPermissionResult.locationPermissionDenied;
      final container = ProviderContainer(
        overrides: [
          runActivityRepositoryProvider.overrideWithValue(
            InMemoryRunActivityRepository(),
          ),
          runSensorServiceProvider.overrideWithValue(sensor),
          runSessionRepositoryProvider.overrideWithValue(
            InMemoryRunSessionRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(runSessionProvider.notifier);
      final started = await notifier.start();

      expect(started, RunPermissionResult.locationPermissionDenied);
      expect(sensor.started, isFalse);
      expect(container.read(runSessionProvider).status, RunSessionStatus.idle);
    });

    test('accumulates GPS distance only during confirmed motion', () async {
      final sensor = FakeRunSensorService();
      final container = ProviderContainer(
        overrides: [
          runActivityRepositoryProvider.overrideWithValue(
            InMemoryRunActivityRepository(),
          ),
          runSensorServiceProvider.overrideWithValue(sensor),
          runSessionRepositoryProvider.overrideWithValue(
            InMemoryRunSessionRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(runSessionProvider.notifier);
      await notifier.start();

      // Anchor point near Inya Lake (Yangon).
      sensor.emit(
        const RunSensorFrame(
          latitude: 16.8388,
          longitude: 96.1440,
          speedMetersPerSecond: 0.0,
          accuracyMeters: 5,
          steps: 3,
          pedestrianStatus: PedestrianState.walking,
          hasStepData: true,
          stepSource: StepDataSource.nativeMotion,
        ),
      );
      await pumpEventQueue();
      // Moving roughly 11 m north (walking pace 1.4 m/s = 5.04 km/h).
      sensor.emit(
        const RunSensorFrame(
          latitude: 16.8389,
          longitude: 96.1440,
          speedMetersPerSecond: 1.4,
          accuracyMeters: 5,
          steps: 3,
          pedestrianStatus: PedestrianState.walking,
          hasStepData: true,
          stepSource: StepDataSource.nativeMotion,
        ),
      );
      await pumpEventQueue();

      final state = container.read(runSessionProvider);
      expect(state.distanceKilometers, greaterThan(0));
      expect(state.distanceKilometers, lessThan(1));
      expect(state.stage, RunStage.walking);
    });

    test(
      'does not register distance or running when the phone is shaken in place',
      () async {
        final sensor = FakeRunSensorService();
        final container = ProviderContainer(
          overrides: [
            runActivityRepositoryProvider.overrideWithValue(
              InMemoryRunActivityRepository(),
            ),
            runSensorServiceProvider.overrideWithValue(sensor),
            runSessionRepositoryProvider.overrideWithValue(
              InMemoryRunSessionRepository(),
            ),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(runSessionProvider.notifier);
        await notifier.start();

        // Stationary coordinates and zero GPS speed must not add distance or
        // classify this frame as movement.
        sensor.emit(
          const RunSensorFrame(
            latitude: 16.8388,
            longitude: 96.1440,
            speedMetersPerSecond: 0.0,
            accuracyMeters: 5,
          ),
        );
        await pumpEventQueue();
        sensor.emit(
          const RunSensorFrame(
            latitude: 16.8388,
            longitude: 96.1440,
            speedMetersPerSecond: 0.0,
            accuracyMeters: 5,
          ),
        );
        await pumpEventQueue();

        final state = container.read(runSessionProvider);
        expect(state.distanceKilometers, 0);
        expect(state.stage, RunStage.stopped);
      },
    );

    test('rejects implausible GPS jumps larger than 40 m per update', () async {
      final sensor = FakeRunSensorService();
      final container = ProviderContainer(
        overrides: [
          runActivityRepositoryProvider.overrideWithValue(
            InMemoryRunActivityRepository(),
          ),
          runSensorServiceProvider.overrideWithValue(sensor),
          runSessionRepositoryProvider.overrideWithValue(
            InMemoryRunSessionRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(runSessionProvider.notifier);
      await notifier.start();

      sensor.emit(
        const RunSensorFrame(
          latitude: 16.8388,
          longitude: 96.1440,
          speedMetersPerSecond: 0.0,
          accuracyMeters: 5,
        ),
      );
      await pumpEventQueue();
      // Huge jump (~1 km) – should be ignored.
      sensor.emit(
        const RunSensorFrame(
          latitude: 16.8488,
          longitude: 96.1440,
          speedMetersPerSecond: 0.0,
          accuracyMeters: 5,
        ),
      );
      await pumpEventQueue();

      expect(container.read(runSessionProvider).distanceKilometers, 0);
    });

    test(
      'motion-only frames update live status before the first GPS fix',
      () async {
        final sensor = FakeRunSensorService();
        final container = ProviderContainer(
          overrides: [
            runActivityRepositoryProvider.overrideWithValue(
              InMemoryRunActivityRepository(),
            ),
            runSensorServiceProvider.overrideWithValue(sensor),
            runSessionRepositoryProvider.overrideWithValue(
              InMemoryRunSessionRepository(),
            ),
          ],
        );
        addTearDown(container.dispose);
        await container.read(runSessionProvider.notifier).start();

        sensor.emit(
          const RunSensorFrame(
            latitude: 0,
            longitude: 0,
            speedMetersPerSecond: 0,
            accuracyMeters: 0,
            steps: 3,
            cadenceStepsPerMinute: 80,
            pedestrianStatus: PedestrianState.walking,
            hasStepData: true,
            hasLocationData: false,
            isLocationUpdate: false,
          ),
        );
        await pumpEventQueue();

        final state = container.read(runSessionProvider);
        expect(state.stage, RunStage.walking);
        expect(state.steps, 3);
        expect(state.distanceKilometers, 0);
      },
    );

    test('GPS distance never fabricates extra step events', () async {
      final sensor = FakeRunSensorService();
      final container = ProviderContainer(
        overrides: [
          runActivityRepositoryProvider.overrideWithValue(
            InMemoryRunActivityRepository(),
          ),
          runSensorServiceProvider.overrideWithValue(sensor),
          runSessionRepositoryProvider.overrideWithValue(
            InMemoryRunSessionRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(runSessionProvider.notifier).start();

      sensor.emit(
        const RunSensorFrame(
          latitude: 16.8388,
          longitude: 96.144,
          speedMetersPerSecond: 1.4,
          accuracyMeters: 5,
          steps: 3,
          pedestrianStatus: PedestrianState.walking,
          hasStepData: true,
          stepSource: StepDataSource.nativeMotion,
        ),
      );
      sensor.emit(
        const RunSensorFrame(
          latitude: 16.8389,
          longitude: 96.144,
          speedMetersPerSecond: 1.4,
          accuracyMeters: 5,
          steps: 3,
          pedestrianStatus: PedestrianState.walking,
          hasStepData: true,
          stepSource: StepDataSource.nativeMotion,
        ),
      );
      await pumpEventQueue();
      final gpsOnlyState = container.read(runSessionProvider);

      expect(gpsOnlyState.distanceKilometers, greaterThan(0));
      expect(gpsOnlyState.steps, 3);
      expect(container.read(runSessionProvider).steps, 3);
      expect(
        container.read(runSessionProvider).stepSource,
        StepDataSource.nativeMotion,
      );
    });

    test(
      'low GPS speed without accepted displacement remains stopped',
      () async {
        final sensor = FakeRunSensorService();
        final clock = MutableClock(DateTime(2026, 8, 31, 6));
        final container = ProviderContainer(
          overrides: [
            runActivityRepositoryProvider.overrideWithValue(
              InMemoryRunActivityRepository(),
            ),
            runSensorServiceProvider.overrideWithValue(sensor),
            runSessionRepositoryProvider.overrideWithValue(
              InMemoryRunSessionRepository(),
            ),
            runNowProvider.overrideWithValue(clock.call),
          ],
        );
        addTearDown(container.dispose);
        await container.read(runSessionProvider.notifier).start();

        sensor.emit(
          RunSensorFrame(
            latitude: 16.8388,
            longitude: 96.144,
            speedMetersPerSecond: 0.2,
            accuracyMeters: 5,
            steps: 0,
            hasStepData: true,
            stepSource: StepDataSource.nativeMotion,
            pedestrianStatus: PedestrianState.walking,
            recordedAt: clock.value,
          ),
        );
        await pumpEventQueue();
        clock.advance(const Duration(seconds: 30));
        sensor.emit(
          RunSensorFrame(
            latitude: 16.838801,
            longitude: 96.144,
            speedMetersPerSecond: 0.2,
            accuracyMeters: 5,
            steps: 0,
            hasStepData: true,
            stepSource: StepDataSource.nativeMotion,
            pedestrianStatus: PedestrianState.walking,
            recordedAt: clock.value,
          ),
        );
        await pumpEventQueue();

        final state = container.read(runSessionProvider);
        expect(state.stage, RunStage.stopped);
        expect(state.steps, 0);
        expect(state.distanceKilometers, 0);
        expect(state.calories, 0);
      },
    );
  });

  group('RunSessionNotifier lifecycle', () {
    ProviderContainer createContainer({
      required FakeRunSensorService sensor,
      required MutableClock clock,
      InMemoryRunSessionRepository? sessionRepository,
      InMemoryRunActivityRepository? activityRepository,
    }) => ProviderContainer(
      overrides: [
        runActivityRepositoryProvider.overrideWithValue(
          activityRepository ?? InMemoryRunActivityRepository(),
        ),
        runSensorServiceProvider.overrideWithValue(sensor),
        runSessionRepositoryProvider.overrideWithValue(
          sessionRepository ?? InMemoryRunSessionRepository(),
        ),
        runNowProvider.overrideWithValue(clock.call),
      ],
    );

    test('pause time is excluded and resume continues active time', () async {
      final clock = MutableClock(DateTime(2026, 8, 31, 6));
      final container = createContainer(
        sensor: FakeRunSensorService(),
        clock: clock,
      );
      addTearDown(container.dispose);
      final notifier = container.read(runSessionProvider.notifier);
      await notifier.start();
      clock.advance(const Duration(seconds: 10));
      await notifier.pause();
      expect(
        container.read(runSessionProvider).elapsed,
        const Duration(seconds: 10),
      );
      clock.advance(const Duration(hours: 1));
      await notifier.resume();
      clock.advance(const Duration(seconds: 5));
      await notifier.pause();
      expect(
        container.read(runSessionProvider).elapsed,
        const Duration(seconds: 15),
      );
    });

    test('can rebuild safely after provider invalidation', () async {
      final sensor = FakeRunSensorService();
      final container = ProviderContainer(
        overrides: [
          runActivityRepositoryProvider.overrideWithValue(
            InMemoryRunActivityRepository(),
          ),
          runSensorServiceProvider.overrideWithValue(sensor),
          runSessionRepositoryProvider.overrideWithValue(
            InMemoryRunSessionRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(runSessionProvider).isIdle, isTrue);

      container.invalidate(runSessionProvider);

      expect(container.read(runSessionProvider).isIdle, isTrue);
    });

    test('native motion steps survive pause and sensor restart', () async {
      final sensor = FakeRunSensorService();
      final clock = MutableClock(DateTime(2026, 8, 31, 6));
      final container = createContainer(sensor: sensor, clock: clock);
      addTearDown(container.dispose);
      final notifier = container.read(runSessionProvider.notifier);
      await notifier.start();
      sensor.emit(
        RunSensorFrame(
          latitude: 16.8388,
          longitude: 96.144,
          speedMetersPerSecond: 1.4,
          accuracyMeters: 5,
          steps: 100,
          hasStepData: true,
          recordedAt: clock.value,
        ),
      );
      await pumpEventQueue();
      await notifier.pause();
      await notifier.resume();
      sensor.emit(
        RunSensorFrame(
          latitude: 16.8388,
          longitude: 96.144,
          speedMetersPerSecond: 1.4,
          accuracyMeters: 5,
          steps: 50,
          hasStepData: true,
          recordedAt: clock.value,
        ),
      );
      await pumpEventQueue();
      expect(container.read(runSessionProvider).steps, 150);
    });

    test('calories integrate each movement stage', () async {
      final sensor = FakeRunSensorService();
      final clock = MutableClock(DateTime(2026, 8, 31, 6));
      final container = createContainer(sensor: sensor, clock: clock);
      addTearDown(container.dispose);
      final notifier = container.read(runSessionProvider.notifier);
      await notifier.start();
      sensor.emit(
        RunSensorFrame(
          latitude: 16.8388,
          longitude: 96.144,
          speedMetersPerSecond: 3,
          accuracyMeters: 5,
          steps: 10,
          cadenceStepsPerMinute: 170,
          pedestrianStatus: PedestrianState.walking,
          hasStepData: true,
          recordedAt: clock.value,
        ),
      );
      await pumpEventQueue();
      clock.advance(const Duration(minutes: 10));
      sensor.emit(
        RunSensorFrame(
          latitude: 16.8388,
          longitude: 96.144,
          speedMetersPerSecond: 1.4,
          accuracyMeters: 5,
          steps: 20,
          cadenceStepsPerMinute: 80,
          pedestrianStatus: PedestrianState.walking,
          hasStepData: true,
          recordedAt: clock.value,
        ),
      );
      await pumpEventQueue();
      clock.advance(const Duration(minutes: 10));
      await notifier.pause();
      final expected =
          RunMetrics.caloriesExactFor(
            RunStage.running,
            const Duration(minutes: 10),
          ) +
          RunMetrics.caloriesExactFor(
            RunStage.walking,
            const Duration(minutes: 10),
          );
      expect(container.read(runSessionProvider).calories, expected.round());
    });

    test('stopped time freezes moving pace and calories', () async {
      final sensor = FakeRunSensorService();
      final clock = MutableClock(DateTime(2026, 8, 31, 6));
      final container = createContainer(sensor: sensor, clock: clock);
      addTearDown(container.dispose);
      await container.read(runSessionProvider.notifier).start();

      sensor.emit(
        RunSensorFrame(
          latitude: 0,
          longitude: 0,
          speedMetersPerSecond: 1.4,
          accuracyMeters: 0,
          steps: 100,
          cadenceStepsPerMinute: 80,
          pedestrianStatus: PedestrianState.walking,
          hasStepData: true,
          hasLocationData: false,
          isLocationUpdate: false,
          recordedAt: clock.value,
        ),
      );
      await pumpEventQueue();
      clock.advance(const Duration(minutes: 1));
      sensor.emit(
        RunSensorFrame(
          latitude: 0,
          longitude: 0,
          speedMetersPerSecond: 1.4,
          accuracyMeters: 0,
          steps: 200,
          cadenceStepsPerMinute: 80,
          pedestrianStatus: PedestrianState.walking,
          hasStepData: true,
          hasLocationData: false,
          isLocationUpdate: false,
          recordedAt: clock.value,
        ),
      );
      await pumpEventQueue();
      sensor.emit(
        RunSensorFrame(
          latitude: 0,
          longitude: 0,
          speedMetersPerSecond: 0,
          accuracyMeters: 0,
          steps: 200,
          cadenceStepsPerMinute: 0,
          pedestrianStatus: PedestrianState.stopped,
          hasStepData: true,
          hasLocationData: false,
          isLocationUpdate: false,
          recordedAt: clock.value,
        ),
      );
      await pumpEventQueue();

      final movingState = container.read(runSessionProvider);
      final paceAtStop = movingState.pacePerKilometer;
      final caloriesAtStop = movingState.calories;

      clock.advance(const Duration(minutes: 10));
      sensor.emit(
        RunSensorFrame(
          latitude: 0,
          longitude: 0,
          speedMetersPerSecond: 0,
          accuracyMeters: 0,
          steps: 200,
          cadenceStepsPerMinute: 0,
          pedestrianStatus: PedestrianState.stopped,
          hasStepData: true,
          hasLocationData: false,
          isLocationUpdate: false,
          recordedAt: clock.value,
        ),
      );
      await pumpEventQueue();

      final stoppedState = container.read(runSessionProvider);
      expect(stoppedState.stage, RunStage.stopped);
      expect(stoppedState.elapsed, const Duration(minutes: 11));
      expect(stoppedState.pacePerKilometer, paceAtStop);
      expect(stoppedState.calories, caloriesAtStop);
    });

    test('empty sessions are discarded and never enter history', () async {
      final clock = MutableClock(DateTime(2026, 8, 31, 6));
      final activities = InMemoryRunActivityRepository();
      final recovery = InMemoryRunSessionRepository();
      final container = createContainer(
        sensor: FakeRunSensorService(),
        clock: clock,
        activityRepository: activities,
        sessionRepository: recovery,
      );
      addTearDown(container.dispose);
      final notifier = container.read(runSessionProvider.notifier);
      await notifier.start();
      expect(await notifier.end(), RunEndResult.discarded);
      expect(await activities.getActivities(), isEmpty);
      expect(recovery.snapshot, isNull);
    });

    test('unfinished session is restored paused', () {
      final startedAt = DateTime(2026, 8, 31, 6);
      final recovery = InMemoryRunSessionRepository(
        RunSessionSnapshot(
          startedAt: startedAt,
          elapsed: const Duration(minutes: 12),
          movingElapsed: const Duration(minutes: 8),
          distanceKilometers: 2.4,
          caloriesExact: 123.4,
          steps: 3100,
          stage: RunStage.jogging,
        ),
      );
      final container = createContainer(
        sensor: FakeRunSensorService(),
        clock: MutableClock(DateTime(2026, 8, 31, 7)),
        sessionRepository: recovery,
      );
      addTearDown(container.dispose);
      final restored = container.read(runSessionProvider);
      expect(restored.status, RunSessionStatus.paused);
      expect(restored.startedAt, startedAt);
      expect(restored.elapsed, const Duration(minutes: 12));
      expect(restored.distanceKilometers, 2.4);
      expect(
        restored.pacePerKilometer,
        const Duration(minutes: 3, seconds: 20),
      );
      expect(restored.steps, 3100);
    });
  });
}
