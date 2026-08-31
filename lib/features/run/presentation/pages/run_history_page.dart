import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/widgets/animated_list_entry.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';
import '../providers/run_providers.dart';
import '../widgets/run_activity_detail_dialog.dart';
import '../widgets/run_day_tile.dart';

@RoutePage()
class RunHistoryPage extends ConsumerWidget {
  const RunHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(runAllHistoryDaysProvider);
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.topHeaderBackground,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.topHeaderBackground,
        body: Stack(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.runGradientStart,
                    AppColors.runGradientEnd,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _HistoryHeader(onBack: context.router.maybePop),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                        physics: const BouncingScrollPhysics(),
                        itemCount: days.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) => AnimatedListEntry(
                          index: index,
                          child: RunDayTile(
                            day: days[index],
                            onTap: () => showRunActivityDetailDialog(
                              context,
                              day: days[index],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (statusBarHeight > 0)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: statusBarHeight,
                child: const ColoredBox(color: AppColors.topHeaderBackground),
              ),
          ],
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 14, 20, 18),
      decoration: const BoxDecoration(color: AppColors.topHeaderBackground),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.defaultPrimaryText,
              size: 20,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'runScreen.historyTitle'.tr(),
                  style: AppTextStyles.semiBold().white
                      .s(22)
                      .copyWith(
                        color: AppColors.defaultPrimaryText,
                        height: 1.15,
                        letterSpacing: -0.31,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  'runScreen.historyDescription'.tr(),
                  style: AppTextStyles.regular().white
                      .s(12)
                      .copyWith(
                        color: AppColors.defaultPrimaryText.withAlpha(179),
                        height: 1.35,
                        letterSpacing: -0.1,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
