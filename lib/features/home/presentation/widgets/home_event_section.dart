import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/assets_constant.dart';
import 'home_event_card.dart';
import 'home_section_header.dart';

class HomeEventSection extends StatelessWidget {
  const HomeEventSection({super.key, this.onShowMore});

  final VoidCallback? onShowMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 24),
          child: HomeSectionHeader(
            title: 'homeScreen.events'.tr(),
            actionLabel: 'homeScreen.showMore'.tr(),
            onActionPressed: onShowMore,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: HomeEventCard.size.height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _eventAssets.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return HomeEventCard(assetPath: _eventAssets[index]);
            },
          ),
        ),
      ],
    );
  }
}

const _eventAssets = [AssetsConstant.eventOne, AssetsConstant.parkRun];
