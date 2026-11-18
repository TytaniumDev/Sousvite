import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/app.dart';

import 'e2e_device.dart';

/// Shows [device]'s app on screen. Only one device has a screen at a time;
/// the others act through their providers, as another phone would.
Future<void> pumpDevice(WidgetTester tester, E2eDevice device) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: device.container,
      child: const SousviteApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Taps the widget [finder] finds, after scrolling it into view, and waits
/// for the screen to settle.
Future<void> tapOn(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Pumps until [finder] finds a widget, then waits for the screen to
/// settle. Screens that show what was just saved wait on database streams,
/// which on a phone can land after `pumpAndSettle` has returned. Fails
/// after [timeout], listing the texts on screen.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final watch = Stopwatch()..start();
  while (finder.evaluate().isEmpty) {
    if (watch.elapsed > timeout) {
      final texts = find
          .byType(Text)
          .evaluate()
          .map((element) => (element.widget as Text).data)
          .nonNulls;
      fail('Never found $finder. On screen: ${texts.join(' | ')}');
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
}
