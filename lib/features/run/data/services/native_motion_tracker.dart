import 'package:flutter/services.dart';

import '../../domain/entities/run_sensor_frame.dart';

/// Native event stream used by the run sensor service.
///
/// Android supplies hardware step-counter and step-detector events. iOS
/// supplies Core Motion pedometer updates and activity confidence. Keeping the
/// platform channel here prevents either platform API from leaking into domain
/// metric calculations.
abstract interface class NativeMotionTracker {
  Stream<NativeMotionEvent> get events;
}

class PlatformNativeMotionTracker implements NativeMotionTracker {
  static const _channel = EventChannel('mingalar_run/native_motion');

  @override
  Stream<NativeMotionEvent> get events => _channel.receiveBroadcastStream().map(
    (event) => NativeMotionEvent.fromPlatform(event),
  );
}

enum NativeMotionEventType {
  stepCounter,
  stepDetector,
  cadence,
  activity,
  availability,
}

class NativeMotionEvent {
  const NativeMotionEvent._({
    required this.type,
    required this.recordedAt,
    this.steps = 0,
    this.isSessionTotal = false,
    this.cadenceStepsPerMinute = 0,
    this.activity = NativeMotionActivity.unknown,
    this.confidence = 0,
    this.isAvailable = true,
  });

  factory NativeMotionEvent.fromPlatform(Object? event) {
    if (event is! Map) {
      throw const FormatException('Native motion event must be a map.');
    }
    final payload = Map<Object?, Object?>.from(event);
    final type = switch (payload['type']) {
      'step_counter' => NativeMotionEventType.stepCounter,
      'step_detector' => NativeMotionEventType.stepDetector,
      'cadence' => NativeMotionEventType.cadence,
      'activity' => NativeMotionEventType.activity,
      'availability' => NativeMotionEventType.availability,
      _ => throw FormatException(
        'Unknown native motion event: ${payload['type']}',
      ),
    };
    final timestamp = payload['timestampMs'];
    final milliseconds = timestamp is num
        ? timestamp.toInt()
        : DateTime.now().millisecondsSinceEpoch;
    return NativeMotionEvent._(
      type: type,
      recordedAt: DateTime.fromMillisecondsSinceEpoch(milliseconds),
      steps: (payload['steps'] as num?)?.toInt() ?? 0,
      isSessionTotal: payload['isSessionTotal'] == true,
      cadenceStepsPerMinute:
          (payload['cadenceStepsPerMinute'] as num?)?.toDouble() ?? 0,
      activity: switch (payload['activity']) {
        'still' => NativeMotionActivity.still,
        'walking' => NativeMotionActivity.walking,
        'running' => NativeMotionActivity.running,
        _ => NativeMotionActivity.unknown,
      },
      confidence: (payload['confidence'] as num?)?.toInt() ?? 0,
      isAvailable: payload['isAvailable'] != false,
    );
  }

  final NativeMotionEventType type;
  final DateTime recordedAt;
  final int steps;
  final bool isSessionTotal;
  final double cadenceStepsPerMinute;
  final NativeMotionActivity activity;
  final int confidence;
  final bool isAvailable;
}
