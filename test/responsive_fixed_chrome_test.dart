import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mingalar_un/core/common/widgets/discovery_page_header.dart';
import 'package:mingalar_un/features/wrapper/presentation/widgets/bottom_nav_item_content.dart';

void main() {
  testWidgets('bottom navigation content fits iOS text metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: BottomNavItemContent(
                icon: Icon(Icons.directions_run_rounded, size: 23),
                label: 'Profile',
                labelStyle: TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('discovery header accommodates iPhone safe area and wrapping', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(390, 844),
            padding: EdgeInsets.only(top: 59),
            textScaler: TextScaler.linear(1.15),
          ),
          child: Scaffold(
            body: Column(
              children: [
                DiscoveryPageHeader(
                  title: 'Running Events',
                  subtitle:
                      'Discover community runs and memorable races near you.',
                  icon: Icons.event_available_rounded,
                ),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Running Events'), findsOneWidget);
    expect(
      find.text('Discover community runs and memorable races near you.'),
      findsOneWidget,
    );
  });
}
