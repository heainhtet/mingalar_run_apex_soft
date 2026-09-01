import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/widgets/animated_list_entry.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/run_providers.dart';
import '../widgets/challenge_run_tab.dart';
import '../widgets/explore_runs_header.dart';
import '../widgets/fun_run_tab.dart';
import '../widgets/personal_run_tab.dart';

@RoutePage()
class RunPage extends ConsumerWidget {
  const RunPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMode = ref.watch(selectedRunTabProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.runGradientStart, AppColors.runGradientEnd],
          ),
        ),
        child: Column(
          children: [
            const AnimatedListEntry(index: 0, child: ExploreRunsHeader()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                physics: const BouncingScrollPhysics(),
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: switch (selectedMode) {
                      0 => const PersonalRunTab(key: ValueKey('personal-run')),
                      1 => const FunRunTab(key: ValueKey('fun-run')),
                      _ => const ChallengeRunTab(
                        key: ValueKey('challenge-run'),
                      ),
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
