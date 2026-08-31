import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/widgets/app_confirmation_dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/logger.dart';
import '../../../events/presentation/pages/events_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../run/presentation/pages/run_page.dart';
import '../../../run/presentation/providers/run_session_provider.dart';
import '../providers/wrapper_provider.dart';
import '../widgets/bottom_navi_widget.dart';

@RoutePage()
class WrapperPage extends ConsumerStatefulWidget {
  const WrapperPage({super.key});

  @override
  ConsumerState<WrapperPage> createState() => _WrapperPageState();
}

class _WrapperPageState extends ConsumerState<WrapperPage>
    with WidgetsBindingObserver {
  final _bodyPages = [
    const HomePage(),
    const RunPage(),
    const EventsPage(),
    const ProfilePage(),
  ];
  bool _exitDialogVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final session = ref.read(runSessionProvider);
    logger.i(
      'App lifecycle=${state.name}, run=${session.status.name}, '
      'elapsed=${session.elapsed.inSeconds}s',
    );
  }

  @override
  Widget build(BuildContext context) {
    final wrapperState = ref.watch(wrapperProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmExit();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
          systemStatusBarContrastEnforced: false,
          systemNavigationBarColor: AppColors.tabIndicatorColor,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarContrastEnforced: false,
        ),
        child: SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: AppColors.white,
            extendBody: true,

            bottomNavigationBar: const BottomNaviWidget(),

            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: KeyedSubtree(
                key: ValueKey<int>(wrapperState.index),
                child: _bodyPages[wrapperState.index],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmExit() async {
    if (_exitDialogVisible || !mounted) return;
    _exitDialogVisible = true;
    final hasActiveRun = ref.read(runSessionProvider).hasStarted;
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'appExit.title'.tr(),
      message: (hasActiveRun ? 'appExit.activeRunMessage' : 'appExit.message')
          .tr(),
      cancelLabel: 'appExit.stay'.tr(),
      confirmLabel: 'appExit.quit'.tr(),
      icon: Icons.logout_rounded,
    );
    _exitDialogVisible = false;
    if (confirmed == true) await SystemNavigator.pop();
  }
}
