import 'package:flutter_test/flutter_test.dart';
import 'package:mingalar_un/features/run/domain/entities/run_sensor_frame.dart';
import 'package:mingalar_un/features/run/domain/services/run_motion_classifier.dart';

void main() {
  final start = DateTime(2026, 9, 1, 8);

  test('does not classify an isolated detector signal as walking', () {
    final classifier = RunMotionClassifier();
    classifier.recordStepDetector(start);

    expect(classifier.classify(start), isStopped);
    expect(
      classifier.classify(start.add(const Duration(seconds: 2))),
      isStopped,
    );
  });

  test('confirms a plausible hardware step rhythm and derives cadence', () {
    final classifier = RunMotionClassifier();
    classifier.recordStepDetector(start);
    classifier.recordStepDetector(start.add(const Duration(milliseconds: 500)));
    classifier.recordStepDetector(
      start.add(const Duration(milliseconds: 1000)),
    );

    final classification = classifier.classify(
      start.add(const Duration(milliseconds: 1000)),
    );

    expect(classification.pedestrianState, PedestrianState.walking);
    expect(classification.cadenceStepsPerMinute, closeTo(120, 0.1));
  });

  test('returns to stopped shortly after confirmed steps stop', () {
    final classifier = RunMotionClassifier();
    classifier.recordStepDetector(start);
    classifier.recordStepDetector(start.add(const Duration(milliseconds: 600)));
    classifier.recordStepDetector(
      start.add(const Duration(milliseconds: 1200)),
    );

    expect(
      classifier
          .classify(start.add(const Duration(milliseconds: 1200)))
          .pedestrianState,
      PedestrianState.walking,
    );
    expect(
      classifier
          .classify(start.add(const Duration(seconds: 5)))
          .pedestrianState,
      PedestrianState.stopped,
    );
  });

  test('rejects implausibly fast detector events', () {
    final classifier = RunMotionClassifier();
    classifier.recordStepDetector(start);
    classifier.recordStepDetector(start.add(const Duration(milliseconds: 80)));
    classifier.recordStepDetector(start.add(const Duration(milliseconds: 160)));
    classifier.recordStepDetector(start.add(const Duration(milliseconds: 240)));

    expect(classifier.classify(start), isStopped);
  });

  test(
    'uses Core Motion session count and cadence when detector events are absent',
    () {
      final classifier = RunMotionClassifier();
      classifier.recordPedometerDelta(
        stepDelta: 3,
        recordedAt: start,
        cadenceStepsPerMinute: 112,
      );

      final classification = classifier.classify(start);

      expect(classification.pedestrianState, PedestrianState.walking);
      expect(classification.cadenceStepsPerMinute, 112);
    },
  );

  test('a recent high-confidence still event ends the active state', () {
    final classifier = RunMotionClassifier();
    classifier.recordStepDetector(start);
    classifier.recordStepDetector(start.add(const Duration(milliseconds: 500)));
    classifier.recordStepDetector(
      start.add(const Duration(milliseconds: 1000)),
    );
    classifier.updateActivity(
      activity: NativeMotionActivity.still,
      confidence: 100,
      recordedAt: start.add(const Duration(milliseconds: 1100)),
    );

    expect(
      classifier
          .classify(start.add(const Duration(milliseconds: 1100)))
          .pedestrianState,
      PedestrianState.stopped,
    );
  });
}

final isStopped = isA<MotionClassification>().having(
  (classification) => classification.pedestrianState,
  'pedestrianState',
  PedestrianState.stopped,
);
