import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/assets_constant.dart';
import '../../../../core/utils/text_extensions.dart';
import '../providers/wrapper_provider.dart';
import 'bottom_nav_item_content.dart';

class BottomNaviWidget extends ConsumerWidget {
  const BottomNaviWidget({super.key});

  static final List<Widget> _icons = [
    SvgPicture.asset(AssetsConstant.homeIcon),
    SvgPicture.asset(
      AssetsConstant.runIcon,
      width: 18,
      height: 22,
      fit: BoxFit.fill,
    ),

    SvgPicture.asset(AssetsConstant.eventsIcon),
    SvgPicture.asset(AssetsConstant.profileIcon),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(wrapperProvider).index;
    final labels = ['home'.tr(), 'run'.tr(), 'events'.tr(), 'profile'.tr()];
    final labelStyle = AppTextStyles.medium().white
        .s(10)
        .copyWith(letterSpacing: 0, height: 0);

    return CurvedNavigationBar(
      index: selectedIndex,
      maxWidth: MediaQuery.of(context).size.width,
      height: 65,
      color: AppColors.tabIndicatorColor,
      backgroundColor: AppColors.defaultPrimaryText,
      buttonBackgroundColor: AppColors.tabIndicatorColor,
      animationDuration: const Duration(milliseconds: 400),
      animationCurve: Curves.easeInOut,
      iconPadding: 8,
      onTap: (index) => ref.read(wrapperProvider.notifier).changeIndex(index),
      letIndexChange: (index) => true,
      items: List.generate(
        _icons.length,
        (index) => CurvedNavigationBarItem(
          child: BottomNavItemContent(
            icon: _icons[index],
            label: labels[index],
            labelStyle: labelStyle,
          ),
        ),
      ),
    );
  }
}
