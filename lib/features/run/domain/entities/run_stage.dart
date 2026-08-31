enum RunStage {
  running(met: 9.8),
  jogging(met: 7),
  walking(met: 3.5),
  stopped(met: 0);

  const RunStage({required this.met});

  final double met;

  static RunStage classify({
    required bool pedestrianWalking,
    double cadence = 0,
  }) {
    if (!pedestrianWalking) return RunStage.stopped;

    if (cadence >= 160) return RunStage.running;
    if (cadence >= 130) return RunStage.jogging;
    return RunStage.walking;
  }

  String get labelKey => switch (this) {
    RunStage.running => 'runScreen.stageRunning',
    RunStage.jogging => 'runScreen.stageJogging',
    RunStage.walking => 'runScreen.stageWalking',
    RunStage.stopped => 'runScreen.stageStopped',
  };

  bool get contributesToRunMetrics => this != RunStage.stopped;
}
