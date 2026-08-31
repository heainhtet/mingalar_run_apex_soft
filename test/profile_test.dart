import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mingalar_un/features/profile/presentation/models/profile_models.dart';
import 'package:mingalar_un/features/profile/presentation/providers/profile_providers.dart';
import 'package:mingalar_un/features/profile/presentation/widgets/profile_summary_card.dart';
import 'package:mingalar_un/features/profile/presentation/widgets/rank_badge.dart';
import 'package:mingalar_un/features/run/domain/entities/run_activity.dart';
import 'package:mingalar_un/features/run/presentation/providers/run_providers.dart';

import 'support/in_memory_repositories.dart';

void main() {
  group('Profile', () {
    testWidgets('renders code-native rank and summary icons', (tester) async {
      final container = ProviderContainer(
        overrides: [
          runActivityRepositoryProvider.overrideWithValue(
            InMemoryRunActivityRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(runActivitiesProvider.future);
      final metrics = container.read(profileSummaryProvider);

      expect(metrics.map((metric) => metric.value), ['0', '0', '0', '0:00']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                const RankBadge(),
                ...metrics.map((metric) => ProfileSummaryCard(metric: metric)),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RankBadge), findsOneWidget);
      expect(find.byIcon(Icons.directions_run_rounded), findsNWidgets(2));
      expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('derives typed summary values from stored runs', () async {
      final repository = InMemoryRunActivityRepository([
        RunActivity(
          id: 'slow-run',
          startedAt: DateTime(2026, 8, 20),
          calories: 120,
          distanceKilometers: 3.25,
          duration: const Duration(minutes: 30),
          pacePerKilometer: const Duration(minutes: 6, seconds: 15),
        ),
        RunActivity(
          id: 'fast-run',
          startedAt: DateTime(2026, 8, 21),
          calories: 85,
          distanceKilometers: 5.0,
          duration: const Duration(minutes: 25),
          pacePerKilometer: const Duration(minutes: 5),
        ),
      ]);
      final container = ProviderContainer(
        overrides: [
          runActivityRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(runActivitiesProvider.future);
      final metrics = container.read(profileSummaryProvider);

      expect(metrics[0].value, '2');
      expect(metrics[1].value, '5.0');
      expect(metrics[2].value, '205');
      expect(metrics[3].value, '5:00');
    });

    test('encodes user information into a machine-readable QR payload', () {
      const profile = UserProfile(
        name: 'Mya Mya',
        phoneNumber: '09 123 456 789',
        tier: 'Gold',
        ionPoints: 591,
      );

      final payload = jsonDecode(profile.qrPayload) as Map<String, dynamic>;

      expect(payload['type'], 'mingalar_run_profile');
      expect(payload['name'], profile.name);
      expect(payload['phoneNumber'], profile.phoneNumber);
      expect(payload['tier'], profile.tier);
      expect(payload['ionPoints'], profile.ionPoints);
    });

    test('decodes only valid Mingalar Run profile QR payloads', () {
      const profile = UserProfile(
        name: 'Mya Mya',
        phoneNumber: '09 123 456 789',
        tier: 'Gold',
        ionPoints: 591,
      );

      final decoded = UserProfile.tryParseQrPayload(profile.qrPayload);

      expect(decoded?.name, profile.name);
      expect(decoded?.phoneNumber, profile.phoneNumber);
      expect(decoded?.tier, profile.tier);
      expect(decoded?.ionPoints, profile.ionPoints);
      expect(UserProfile.tryParseQrPayload('not-json'), isNull);
      expect(UserProfile.tryParseQrPayload('{"type":"unrelated_qr"}'), isNull);
    });

    test('saves trimmed profile information without setState', () async {
      final repository = InMemoryProfileRepository(
        initialProfile: const UserProfile(
          name: 'Existing User',
          phoneNumber: '09 000 000 000',
          tier: 'Gold',
          ionPoints: 591,
        ),
      );
      final container = ProviderContainer(
        overrides: [profileRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(profileProvider.future);
      final controller = container.read(profileProvider.notifier);

      await controller.saveProfile(
        name: '  Mya Mya  ',
        phoneNumber: '  09 123 456 789  ',
      );

      final state = container.read(profileProvider).requireValue;
      expect(state.isSaving, isFalse);
      expect(state.user?.name, 'Mya Mya');
      expect(state.user?.phoneNumber, '09 123 456 789');
      expect(state.user?.tier, 'Gold');
      expect(state.user?.ionPoints, 591);
    });
  });
}
