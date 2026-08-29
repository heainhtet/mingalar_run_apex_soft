import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../events/presentation/pages/events_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../run/presentation/pages/run_page.dart';
import '../providers/wrapper_provider.dart';
import '../widgets/bottom_navi_widget.dart';

@RoutePage()
class WrapperPage extends ConsumerStatefulWidget {
  const WrapperPage({super.key});

  @override
  ConsumerState<WrapperPage> createState() => _WrapperPageState();
}

class _WrapperPageState extends ConsumerState<WrapperPage> {
  final _bodyPages = [
    const HomePage(),
    const RunPage(),
    const EventsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final wrapperState = ref.watch(wrapperProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
      child: SafeArea(
        top: false,
        bottom: false,
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
    );
  }
}
