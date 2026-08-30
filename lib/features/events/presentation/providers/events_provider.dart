import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/assets_constant.dart';
import '../models/event_preview.dart';

final eventCatalogProvider = Provider<List<EventPreview>>((ref) {
  return const [
    EventPreview(
      titleKey: 'eventsScreen.cityMarathon.title',
      descriptionKey: 'eventsScreen.cityMarathon.description',
      assetPath: AssetsConstant.cityMarathon,
      badgeKey: 'eventsScreen.open',
      date: '14 Sep',
      location: 'Yangon',
      distance: '10 km',
      category: EventCategory.upcoming,
    ),
    EventPreview(
      titleKey: 'eventsScreen.forestRun.title',
      descriptionKey: 'eventsScreen.forestRun.description',
      assetPath: AssetsConstant.forestTrail,
      badgeKey: 'eventsScreen.limited',
      date: '28 Sep',
      location: 'Pyin Oo Lwin',
      distance: '5 km',
      category: EventCategory.upcoming,
    ),
    EventPreview(
      titleKey: 'eventsScreen.communityRun.title',
      descriptionKey: 'eventsScreen.communityRun.description',
      assetPath: AssetsConstant.communityRun,
      badgeKey: 'eventsScreen.free',
      date: '05 Oct',
      location: 'Mandalay',
      distance: '3 km',
      category: EventCategory.thisMonth,
    ),
    EventPreview(
      titleKey: 'eventsScreen.sunsetRun.title',
      descriptionKey: 'eventsScreen.sunsetRun.description',
      assetPath: AssetsConstant.sunsetRun,
      badgeKey: 'eventsScreen.open',
      date: '12 Oct',
      location: 'Nay Pyi Taw',
      distance: '7 km',
      category: EventCategory.thisMonth,
    ),
    EventPreview(
      titleKey: 'eventsScreen.lakeRun.title',
      descriptionKey: 'eventsScreen.lakeRun.description',
      assetPath: AssetsConstant.lakeRun,
      badgeKey: 'eventsScreen.nearYou',
      date: 'This Sat',
      location: 'Inya Lake',
      distance: '4 km',
      category: EventCategory.nearby,
    ),
    EventPreview(
      titleKey: 'eventsScreen.weekendRun.title',
      descriptionKey: 'eventsScreen.weekendRun.description',
      assetPath: AssetsConstant.parkRun,
      badgeKey: 'eventsScreen.free',
      date: 'This Sun',
      location: 'People’s Park',
      distance: '5 km',
      category: EventCategory.nearby,
    ),
  ];
});

final eventsByCategoryProvider =
    Provider.family<List<EventPreview>, EventCategory>((ref, category) {
      final events = ref.watch(eventCatalogProvider);
      return events.where((event) => event.category == category).toList();
    });
