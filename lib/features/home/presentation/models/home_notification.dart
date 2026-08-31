enum HomeNotificationType { activeRun, completedRun, welcome }

class HomeNotification {
  const HomeNotification({
    required this.id,
    required this.type,
    required this.createdAt,
    this.distanceKilometers = 0,
    this.duration = Duration.zero,
    this.calories = 0,
  });

  final String id;
  final HomeNotificationType type;
  final DateTime createdAt;
  final double distanceKilometers;
  final Duration duration;
  final int calories;
}
