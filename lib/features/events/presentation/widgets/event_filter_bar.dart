import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';

class EventCategoryTabBar extends StatelessWidget {
  const EventCategoryTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider(context)),
      ),
      child: TabBar(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.tabIndicatorColor,
          borderRadius: BorderRadius.circular(20),
        ),
        labelColor: AppColors.defaultPrimaryText,
        unselectedLabelColor: AppColors.secondaryText(context),
        labelStyle: AppTextStyles.medium()
            .s(12)
            .copyWith(height: 1, letterSpacing: 0),
        unselectedLabelStyle: AppTextStyles.medium()
            .s(12)
            .copyWith(height: 1, letterSpacing: 0),
        tabs: [
          Tab(text: 'eventsScreen.upcoming'.tr()),
          Tab(text: 'eventsScreen.thisMonth'.tr()),
          Tab(text: 'eventsScreen.nearby'.tr()),
        ],
      ),
    );
  }
}
