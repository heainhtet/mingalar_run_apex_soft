import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import 'core/database/hive_database.dart';
import 'core/routers/app_router.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/app_colors.dart';
import 'core/utils/app_platform.dart';
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
  final initialLanguage = AppLanguage.fromCode(
    Hive.box<String>(HiveBoxNames.settings).get(HiveKeys.language),
  );
  logger.i(
    'Mingalar Run application initialized on ${AppPlatform.operatingSystem}',
  );

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('my', 'MM')],
        path: 'assets/translations',
        startLocale: initialLanguage.locale,
        fallbackLocale: const Locale('en', 'US'),
        useFallbackTranslations: true,
        assetLoader: const RootBundleAssetLoader(),
        useOnlyLangCode: false,
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return MaterialApp.router(
      title: 'Mingalar Run',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            systemNavigationBarColor: isDark
                ? const Color(0xFF0A1D50)
                : AppColors.tabIndicatorColor,
            systemNavigationBarDividerColor: isDark
                ? const Color(0xFF0A1D50)
                : AppColors.tabIndicatorColor,
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarContrastEnforced: false,
          ),
          child: ColoredBox(
            color: isDark
                ? const Color(0xFF0A1D50)
                : AppColors.tabIndicatorColor,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppColors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryButtonColor,
          brightness: Brightness.light,
        ),
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
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryButtonColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF081126),
        dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF121C33)),
      ),
      themeMode: settings.themeMode,
      routerDelegate: router.delegate(),
      routeInformationParser: router.defaultRouteParser(),
    );
  }
}
