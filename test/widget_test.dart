import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mingalar_un/features/run/presentation/models/run_calendar_models.dart';
import 'package:mingalar_un/features/run/presentation/providers/run_providers.dart';

import 'support/in_memory_repositories.dart';

void main() {
  group('Run calendar providers', () {
    late ProviderContainer container;

    setUp(() {
      final activities = [
        RunActivity(
          id: 'run-1',
          startedAt: DateTime(2026, 8, 4, 4, 19),
          calories: 120,
          distanceKilometers: 1.4,
          duration: const Duration(minutes: 45),
          pacePerKilometer: const Duration(minutes: 7, seconds: 30),
        ),
        RunActivity(
          id: 'run-2',
          startedAt: DateTime(2026, 8, 2, 21, 34),
          calories: 98,
          distanceKilometers: 1.1,
          duration: const Duration(minutes: 32),
          pacePerKilometer: const Duration(minutes: 8, seconds: 5),
        ),
      ];
      container = ProviderContainer(
        overrides: [
          runCurrentDateProvider.overrideWithValue(DateTime(2026, 8, 5, 12)),
          runActivityRepositoryProvider.overrideWithValue(
            InMemoryRunActivityRepository(activities),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('builds previous and current calendar weeks from Sunday', () async {
      await container.read(runActivitiesProvider.future);
      final days = container.read(runCalendarDaysProvider);

      expect(days, hasLength(14));
      expect(days.first.date, DateTime(2026, 7, 26));
      expect(days.last.date, DateTime(2026, 8, 8));
      expect(
        days.singleWhere((day) => day.date.day == 5).status,
        RunCalendarStatus.today,
      );
    });

    test('builds every day in the real current month', () async {
      await container.read(runActivitiesProvider.future);
      final days = container.read(runCurrentMonthCalendarDaysProvider);

      expect(days, hasLength(31));
      expect(days.first.date, DateTime(2026, 8, 1));
      expect(days.last.date, DateTime(2026, 8, 31));
    });

    test('derives completed calendar days from stored activities', () async {
      await container.read(runActivitiesProvider.future);
      final days = container.read(runCalendarDaysProvider);

      expect(
        days.singleWhere((day) => day.date.day == 2).status,
        RunCalendarStatus.completeRecord,
      );
      expect(
        days.singleWhere((day) => day.date.day == 4).status,
        RunCalendarStatus.completeRecord,
      );
    });

    test('records a completed run with calculated pace', () async {
      await container.read(runActivitiesProvider.future);

      await container
          .read(runActivitiesProvider.notifier)
          .recordCompletedRun(
            startedAt: DateTime(2026, 8, 5, 7),
            calories: 250,
            distanceKilometers: 5,
            duration: const Duration(minutes: 25),
            steps: 6200,
          );

      final saved = container.read(runActivitiesProvider).requireValue.first;
      expect(saved.calories, 250);
      expect(saved.distanceKilometers, 5.0);
      expect(saved.steps, 6200);
      expect(saved.pacePerKilometer, const Duration(minutes: 5));
      expect(
        container
            .read(runCurrentMonthCalendarDaysProvider)
            .singleWhere((day) => day.date.day == 5)
            .status,
        RunCalendarStatus.completeRecord,
      );
    });
  });
}
