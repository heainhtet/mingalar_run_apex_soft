class CMPedometerData {
  const CMPedometerData({
    required this.numberOfSteps,
    required this.timeStamp,
    this.distance,
    this.averageActivePace,
    this.currentPace,
    this.currentCadence,
  });

  factory CMPedometerData.fromJson(Map<Object?, Object?> value) {
    double? number(Object? input) => input is num ? input.toDouble() : null;

    return CMPedometerData(
      numberOfSteps: (value['numberOfSteps'] as num?)?.toInt() ?? 0,
      timeStamp: DateTime.now(),
      distance: number(value['distance']),
      averageActivePace: number(value['averageActivePace']),
      currentPace: number(value['currentPace']),
      currentCadence: number(value['currentCadence']),
    );
  }

  final int numberOfSteps;
  final DateTime timeStamp;
  final double? distance;
  final double? averageActivePace;
  final double? currentPace;
  final double? currentCadence;
}
