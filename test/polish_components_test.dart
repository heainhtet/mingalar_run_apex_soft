import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mingalar_un/core/common/widgets/app_flushbar.dart';
import 'package:mingalar_un/core/routers/app_router.dart';
import 'package:mingalar_un/core/routers/app_router.gr.dart';
import 'package:mingalar_un/core/theme/app_colors.dart';
import 'package:mingalar_un/features/run/presentation/providers/run_providers.dart';
import 'package:mingalar_un/features/run/presentation/widgets/run_calendar_dialog.dart';
import 'package:mingalar_un/features/run/presentation/widgets/run_end_confirmation_dialog.dart';

import 'support/in_memory_repositories.dart';

void main() {
  testWidgets('themed flushbar presents and dismisses safely', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => AppFlushbar.info(context, 'Tracking ready'),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Tracking ready'), findsOneWidget);
    expect(tester.takeException(), isNull);

    for (var frame = 0; frame < 40; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('end run confirmation returns the selected action', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showRunEndConfirmationDialog(context);
              },
              child: const Text('End run'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('End run'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.stop_rounded), findsOneWidget);

    await tester.tap(find.text('runScreen.confirmEnd'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('monthly calendar fits an iPhone-sized viewport', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          runActivityRepositoryProvider.overrideWithValue(
            InMemoryRunActivityRepository(),
          ),
          runCurrentDateProvider.overrideWithValue(DateTime(2026, 8, 31)),
        ],
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              padding: EdgeInsets.only(top: 59, bottom: 34),
            ),
            child: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showRunCalendarDialog(context),
                  child: const Text('Calendar'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();

    expect(find.byType(RunCalendarDialog), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('run history status bar matches its header', (tester) async {
    final router = AppRouter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          runActivityRepositoryProvider.overrideWithValue(
            InMemoryRunActivityRepository(),
          ),
          runCurrentDateProvider.overrideWithValue(DateTime(2026, 8, 31)),
        ],
        child: MaterialApp.router(
          routerDelegate: router.delegate(
            deepLinkBuilder: (_) => DeepLink(const [RunHistoryRoute()]),
          ),
          routeInformationParser: router.defaultRouteParser(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final overlayStyles = tester
        .widgetList<AnnotatedRegion<SystemUiOverlayStyle>>(
          find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
        )
        .map((region) => region.value);
    expect(
      overlayStyles.any(
        (style) =>
            style.statusBarColor == AppColors.topHeaderBackground &&
            style.statusBarIconBrightness == Brightness.light,
      ),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
}
