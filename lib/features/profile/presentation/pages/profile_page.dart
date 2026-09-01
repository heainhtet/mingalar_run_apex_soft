import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/common/widgets/animated_list_entry.dart';
import '../../../../core/routers/app_router.gr.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../run/presentation/providers/run_providers.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_detail_dialog.dart';
import '../widgets/profile_identity_card.dart';
import '../widgets/profile_qr_dialog.dart';
import '../widgets/profile_run_history_section.dart';
import '../widgets/profile_summary_section.dart';

@RoutePage()
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider).value;
    final summary = ref.watch(profileSummaryProvider);
    final rank = ref.watch(profileRankProvider);
    final lastSevenDays = ref.watch(runLastSevenDaysProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.profileGradientStart,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.profileGradient(context),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 122),
              physics: const BouncingScrollPhysics(),
              children: [
                AnimatedListEntry(
                  index: 0,
                  child: ProfileHeader(
                    onScanPressed: () =>
                        context.router.push(const ProfileQrScannerRoute()),
                    onSettingsPressed: () =>
                        context.router.push(const ProfileSettingsRoute()),
                  ),
                ),
                const Gap(22),
                AnimatedListEntry(
                  index: 1,
                  child: ProfileIdentityCard(
                    user: profileState?.user,
                    onQrPressed: () => showProfileQrDialog(context, ref),
                    onAvatarPressed: () =>
                        showProfileEditorDialog(context, ref),
                    rank: rank,
                  ),
                ),
                const Gap(44),
                AnimatedListEntry(
                  index: 2,
                  child: ProfileSummarySection(metrics: summary),
                ),
                const Gap(44),
                AnimatedListEntry(
                  index: 3,
                  child: ProfileRunHistorySection(
                    days: lastSevenDays,
                    onShowAll: () =>
                        context.router.push(const RunHistoryRoute()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
