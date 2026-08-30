import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routers/app_router.dart';
import 'core/database/hive_database.dart';
import 'core/theme/app_colors.dart';

final router = AppRouter();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await HiveDatabase.initialize();

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('my', 'MM')],
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
      theme: ThemeData(
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.black,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppColors.white,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
      ),
      routerDelegate: router.delegate(),
      routeInformationParser: router.defaultRouteParser(),
    );
  }
}
