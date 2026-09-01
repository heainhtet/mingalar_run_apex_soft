import 'package:flutter/services.dart';

import 'cm_pedometer_data.dart';

class CMPedometer {
  const CMPedometer._();

  static const EventChannel _stepCounter = EventChannel('step_counter_first');
  static const EventChannel _pedestrianStatus = EventChannel('step_detection');

  static Stream<CMPedometerData> stepCounterFirstStream({DateTime? from}) {
    return _stepCounter
        .receiveBroadcastStream(
          from == null ? null : {'startDate': from.millisecondsSinceEpoch},
        )
        .map(
          (event) => CMPedometerData.fromJson(
            Map<Object?, Object?>.from(event as Map),
          ),
        );
  }

  static Stream<CMPedestrianStatus> get pedestrianStatusStream =>
      _pedestrianStatus
          .receiveBroadcastStream()
          .map((event) => CMPedestrianStatus._(event as int));
}

class CMPedestrianStatus {
  const CMPedestrianStatus._(this._value);

  final int _value;

  String get status {
    if (_value == 0) return 'stopped';
    if (_value == 1) return 'walking';
    return 'unknown';
  }

  DateTime get timeStamp => DateTime.now();
}
