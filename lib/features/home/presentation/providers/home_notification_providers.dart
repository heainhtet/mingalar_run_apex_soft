import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../run/presentation/providers/run_providers.dart';
import '../../../run/presentation/providers/run_session_provider.dart';
import '../models/home_notification.dart';

final homeNotificationsProvider = Provider<List<HomeNotification>>((ref) {
  final session = ref.watch(runSessionProvider);
  final activities = ref.watch(runActivitiesProvider).value ?? const [];
  final notifications = <HomeNotification>[];

  if (session.hasStarted) {
    notifications.add(
      HomeNotification(
        id: 'active-run',
        type: HomeNotificationType.activeRun,
        createdAt: session.startedAt ?? DateTime.now(),
        distanceKilometers: session.distanceKilometers,
        duration: session.elapsed,
        calories: session.calories,
      ),
    );
  }

  notifications.addAll(
    activities
        .take(10)
        .map(
          (activity) => HomeNotification(
            id: activity.id,
            type: HomeNotificationType.completedRun,
            createdAt: activity.startedAt,
            distanceKilometers: activity.distanceKilometers,
            duration: activity.duration,
            calories: activity.calories,
          ),
        ),
  );

  if (notifications.isEmpty) {
    notifications.add(
      HomeNotification(
        id: 'welcome',
        type: HomeNotificationType.welcome,
        createdAt: DateTime.now(),
      ),
    );
  }
  return notifications;
});
