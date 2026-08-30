import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/widgets/animated_list_entry.dart';
import '../../../../core/common/widgets/discovery_card.dart';
import '../models/event_preview.dart';
import '../providers/events_provider.dart';

class EventListTab extends ConsumerWidget {
  const EventListTab({super.key, required this.category});

  final EventCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsByCategoryProvider(category));

    return ListView.separated(
      key: PageStorageKey(category),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      physics: const BouncingScrollPhysics(),
      itemCount: events.length,
      separatorBuilder: (_, _) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final event = events[index];

        return AnimatedListEntry(
          index: index,
          child: DiscoveryCard(
            assetPath: event.assetPath,
            title: event.titleKey.tr(),
            subtitle: event.descriptionKey.tr(),
            badge: event.badgeKey.tr(),
            metadata: [
              DiscoveryMetadata(
                icon: Icons.calendar_month_outlined,
                label: event.date,
              ),
              DiscoveryMetadata(
                icon: Icons.location_on_outlined,
                label: event.location,
              ),
              DiscoveryMetadata(
                icon: Icons.route_rounded,
                label: event.distance,
              ),
            ],
          ),
        );
      },
    );
  }
}
