import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routers/app_router.dart';
import 'core/database/hive_database.dart';
import 'core/theme/app_colors.dart';
import 'core/utils/logger.dart';

final router = AppRouter();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    logger.e(
      'Unhandled Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    logger.e(
      'Unhandled asynchronous application error',
      error: error,
      stackTrace: stackTrace,
    );
    return true;
  };
  await EasyLocalization.ensureInitialized();
  await HiveDatabase.initialize();
  logger.i('Mingalar Run application initialized');

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('en', 'US')],
        path: 'assets/translations',
        startLocale: const Locale('en', 'US'),
        fallbackLocale: const Locale('en', 'US'),
        assetLoader: const RootBundleAssetLoader(),
        useOnlyLangCode: false,
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mingalar Run',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            systemNavigationBarColor: AppColors.tabIndicatorColor,
            systemNavigationBarDividerColor: AppColors.tabIndicatorColor,
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarContrastEnforced: false,
          ),
          child: ColoredBox(
            color: AppColors.tabIndicatorColor,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      theme: ThemeData(
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.black,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppColors.white,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: AppColors.tabIndicatorColor,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        ),
      ),
      routerDelegate: router.delegate(),
      routeInformationParser: router.defaultRouteParser(),
    );
  }
}
