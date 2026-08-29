import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: OnBoardingRoute.page),
    AutoRoute(page: WrapperRoute.page),
    AutoRoute(page: HomeRoute.page),
    AutoRoute(page: RunRoute.page),
    AutoRoute(page: EventsRoute.page),
    AutoRoute(page: ProfileRoute.page),
  ];
}
