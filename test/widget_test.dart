import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mingalar_un/features/run/presentation/models/run_calendar_models.dart';
import 'package:mingalar_un/features/run/presentation/providers/run_providers.dart';

void main() {
  group('Run calendar providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          runCurrentDateProvider.overrideWithValue(DateTime(2026, 8, 5, 12)),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('builds two real calendar weeks beginning on Sunday', () {
      final days = container.read(runCalendarDaysProvider);

      expect(days, hasLength(14));
      expect(days.first.date, DateTime(2026, 8, 2));
      expect(days.last.date, DateTime(2026, 8, 15));
      expect(
        days.singleWhere((day) => day.date.day == 5).status,
        RunCalendarStatus.today,
      );
    });

    test('derives completed calendar days from modeled activities', () {
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
  });
}
