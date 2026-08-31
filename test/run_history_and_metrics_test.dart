import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mingalar_un/features/run/domain/entities/run_activity.dart';
import 'package:mingalar_un/features/run/presentation/providers/run_providers.dart';
import 'package:mingalar_un/features/run/presentation/providers/run_session_provider.dart';
import 'package:mingalar_un/core/utils/measurement_formatter.dart';

import 'support/in_memory_repositories.dart';

void main() {
  group('runLastThreeDaysProvider', () {
    test(
      'returns three zero-default days when there are no activities',
      () async {
        final container = ProviderContainer(
          overrides: [
            runActivityRepositoryProvider.overrideWithValue(
              InMemoryRunActivityRepository(),
            ),
            runCurrentDateProvider.overrideWithValue(DateTime(2026, 8, 30, 10)),
          ],
        );
        addTearDown(container.dispose);

        await container.read(runActivitiesProvider.future);
        final days = container.read(runLastThreeDaysProvider);

        expect(days.length, 3);
        expect(days.every((day) => !day.hasActivity), isTrue);
        expect(days.every((day) => day.calories == 0), isTrue);
        expect(days.every((day) => day.distanceKilometers == 0), isTrue);
        expect(days.every((day) => day.duration == Duration.zero), isTrue);
        expect(days.every((day) => day.pacePerKilometer == null), isTrue);
        expect(days[0].date, DateTime(2026, 8, 30));
        expect(days[1].date, DateTime(2026, 8, 29));
        expect(days[2].date, DateTime(2026, 8, 28));
      },
    );

    test('aggregates today activity and keeps other days at zero', () async {
      final repository = InMemoryRunActivityRepository([
        RunActivity(
          id: 'today-run',
          startedAt: DateTime(2026, 8, 30, 6, 30),
          calories: 210,
          distanceKilometers: 4.75,
          duration: const Duration(minutes: 28),
          pacePerKilometer: const Duration(minutes: 5, seconds: 54),
          steps: 5800,
        ),
      ]);
      final container = ProviderContainer(
        overrides: [
          runActivityRepositoryProvider.overrideWithValue(repository),
          runCurrentDateProvider.overrideWithValue(DateTime(2026, 8, 30, 10)),
        ],
      );
      addTearDown(container.dispose);

      await container.read(runActivitiesProvider.future);
      final days = container.read(runLastThreeDaysProvider);

      expect(days.length, 3);
      expect(days[0].hasActivity, isTrue);
      expect(days[1].hasActivity, isFalse);
      expect(days[2].hasActivity, isFalse);
      expect(days[0].calories, 210);
      expect(days[0].distanceKilometers, 4.75);
      expect(days[0].duration, const Duration(minutes: 28));
      expect(
        days[0].pacePerKilometer,
        Duration(milliseconds: (28 * 60 * 1000 / 4.75).round()),
      );
      expect(days[0].steps, 5800);
    });
  });

  test(
    'runLastSevenDaysProvider returns a rolling week newest first',
    () async {
      final container = ProviderContainer(
        overrides: [
          runActivityRepositoryProvider.overrideWithValue(
            InMemoryRunActivityRepository(),
          ),
          runCurrentDateProvider.overrideWithValue(DateTime(2026, 8, 30, 10)),
        ],
      );
      addTearDown(container.dispose);

      await container.read(runActivitiesProvider.future);
      final days = container.read(runLastSevenDaysProvider);

      expect(days, hasLength(7));
      expect(days.first.date, DateTime(2026, 8, 30));
      expect(days.last.date, DateTime(2026, 8, 24));
    },
  );

  test(
    'runAllHistoryDaysProvider returns recorded days newest first',
    () async {
      final repository = InMemoryRunActivityRepository([
        RunActivity(
          id: 'older-run',
          startedAt: DateTime(2026, 7, 2, 6),
          calories: 100,
          distanceKilometers: 2,
          duration: const Duration(minutes: 15),
          pacePerKilometer: const Duration(minutes: 7, seconds: 30),
          steps: 2600,
        ),
        RunActivity(
          id: 'newer-run',
          startedAt: DateTime(2026, 8, 28, 6),
          calories: 200,
          distanceKilometers: 4,
          duration: const Duration(minutes: 25),
          pacePerKilometer: const Duration(minutes: 6, seconds: 15),
          steps: 5200,
        ),
      ]);
      final container = ProviderContainer(
        overrides: [
          runActivityRepositoryProvider.overrideWithValue(repository),
          runCurrentDateProvider.overrideWithValue(DateTime(2026, 8, 30, 10)),
        ],
      );
      addTearDown(container.dispose);

      await container.read(runActivitiesProvider.future);
      final days = container.read(runAllHistoryDaysProvider);

      expect(days, hasLength(2));
      expect(days.first.date, DateTime(2026, 8, 28));
      expect(days.last.date, DateTime(2026, 7, 2));
    },
  );

  group('RunMetrics', () {
    test('derives pace and active calories', () {
      const elapsed = Duration(minutes: 30);
      const distance = 5.0;
      final pace = RunMetrics.paceFor(distance, elapsed);
      final calories = RunMetrics.caloriesFor(RunStage.running, elapsed);

      expect(pace, const Duration(minutes: 6));
      expect(calories, closeTo(360, 1));
    });
  });

  test(
    'formats short distances in metres and longer distances in kilometres',
    () {
      expect(MeasurementFormatter.distance(0).label, '0 m');
      expect(MeasurementFormatter.distance(0.034).label, '34 m');
      expect(MeasurementFormatter.distance(1.45).label, '1.4 km');
    },
  );
}
