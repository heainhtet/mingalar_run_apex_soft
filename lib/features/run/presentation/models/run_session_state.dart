import '../../domain/entities/run_stage.dart';
import '../../domain/entities/run_sensor_frame.dart';

enum RunSessionStatus { idle, running, paused }

enum RunEndResult { saved, discarded }

class RunSessionState {
  const RunSessionState({
    this.status = RunSessionStatus.idle,
    this.stage = RunStage.stopped,
    this.stepSource = StepDataSource.unavailable,
    this.startedAt,
    this.elapsed = Duration.zero,
    this.distanceKilometers = 0,
    this.pacePerKilometer,
    this.calories = 0,
    this.steps = 0,
    this.isSaving = false,
    this.sensorError,
  });

  final RunSessionStatus status;
  final RunStage stage;
  final StepDataSource stepSource;
  final DateTime? startedAt;
  final Duration elapsed;
  final double distanceKilometers;
  final Duration? pacePerKilometer;
  final int calories;
  final int steps;
  final bool isSaving;
  final String? sensorError;

  bool get isIdle => status == RunSessionStatus.idle;
  bool get isRunning => status == RunSessionStatus.running;
  bool get isPaused => status == RunSessionStatus.paused;
  bool get hasStarted => status != RunSessionStatus.idle;

  RunSessionState copyWith({
    RunSessionStatus? status,
    RunStage? stage,
    StepDataSource? stepSource,
    DateTime? startedAt,
    Duration? elapsed,
    double? distanceKilometers,
    Duration? pacePerKilometer,
    bool clearPace = false,
    int? calories,
    int? steps,
    bool? isSaving,
    String? sensorError,
    bool clearSensorError = false,
  }) => RunSessionState(
    status: status ?? this.status,
    stage: stage ?? this.stage,
    stepSource: stepSource ?? this.stepSource,
    startedAt: startedAt ?? this.startedAt,
    elapsed: elapsed ?? this.elapsed,
    distanceKilometers: distanceKilometers ?? this.distanceKilometers,
    pacePerKilometer: clearPace
        ? null
        : pacePerKilometer ?? this.pacePerKilometer,
    calories: calories ?? this.calories,
    steps: steps ?? this.steps,
    isSaving: isSaving ?? this.isSaving,
    sensorError: clearSensorError ? null : sensorError ?? this.sensorError,
  );
}
