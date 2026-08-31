import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';
import '../providers/run_providers.dart';

class ExploreRunsHeader extends ConsumerWidget {
  const ExploreRunsHeader({super.key, this.onTabSelected});

  final ValueChanged<int>? onTabSelected;

  static const _tabLabels = [
    'runScreen.personalRun',
    'runScreen.funRun',
    'runScreen.challengeRun',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedRunTabProvider);

    return Container(
      decoration: const BoxDecoration(color: AppColors.topHeaderBackground),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'runScreen.title'.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.medium().white
                    .s(14)
                    .copyWith(
                      color: AppColors.defaultPrimaryText,
                      height: 1,
                      letterSpacing: -0.31,
                    ),
              ),
              Gap(26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_tabLabels.length, (index) {
                  return _RunTab(
                    label: _tabLabels[index].tr().toUpperCase(),
                    isSelected: index == selectedIndex,
                    onTap: () {
                      ref.read(selectedRunTabProvider.notifier).select(index);
                      onTabSelected?.call(index);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RunTab extends StatelessWidget {
  const _RunTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tabIndicatorColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.semiBold().white
              .s(10)
              .copyWith(
                color: isSelected
                    ? AppColors.defaultPrimaryText
                    : AppColors.defaultPrimaryText.withValues(alpha: 0.45),
                height: 1,
                letterSpacing: 0,
              ),
        ),
      ),
    );
  }
}
