enum EventCategory { upcoming, thisMonth, nearby }

class EventPreview {
  const EventPreview({
    required this.titleKey,
    required this.descriptionKey,
    required this.assetPath,
    required this.badgeKey,
    required this.date,
    required this.location,
    required this.distance,
    required this.category,
  });

  final String titleKey;
  final String descriptionKey;
  final String assetPath;
  final String badgeKey;
  final String date;
  final String location;
  final String distance;
  final EventCategory category;
}
