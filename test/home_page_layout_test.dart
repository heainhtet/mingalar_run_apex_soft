import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mingalar_un/features/home/presentation/pages/home_page.dart';
import 'package:mingalar_un/features/run/presentation/providers/run_session_provider.dart';

class _IdleRunSessionNotifier extends RunSessionNotifier {
  @override
  RunSessionState build() => const RunSessionState();
}

void main() {
  testWidgets('Home keeps its fixed header within viewport constraints', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          runSessionProvider.overrideWith(_IdleRunSessionNotifier.new),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
  });
}
