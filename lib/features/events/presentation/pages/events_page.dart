import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/common/widgets/discovery_page_header.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/event_preview.dart';
import '../widgets/event_filter_bar.dart';
import '../widgets/event_list_tab.dart';

@RoutePage()
class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: EventCategory.values.length,
      child: Scaffold(
        backgroundColor: AppColors.pageBackground(context),
        body: Column(
          children: [
            DiscoveryPageHeader(
              title: 'eventsScreen.title'.tr(),
              subtitle: 'eventsScreen.subtitle'.tr(),
              icon: Icons.event_available_rounded,
            ),

            Gap(20),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: EventCategoryTabBar(),
            ),

            Gap(20),

            const Expanded(
              child: TabBarView(
                physics: BouncingScrollPhysics(),
                children: [
                  EventListTab(category: EventCategory.upcoming),
                  EventListTab(category: EventCategory.thisMonth),
                  EventListTab(category: EventCategory.nearby),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
