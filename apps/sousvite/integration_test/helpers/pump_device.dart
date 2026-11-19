import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/app.dart';

import 'e2e_device.dart';

/// Shows [device]'s app on screen. Only one device has a screen at a time;
/// the others act through their providers, as another phone would.
///
/// Text goes in through Flutter's stand-in keyboard, as in widget tests.
/// With the device's real keyboard, `enterText` changes a field without
/// telling that keyboard, which on Android later sends its old text back
/// and undoes the edit. The flows test the app, not the keyboard.
Future<void> pumpDevice(WidgetTester tester, E2eDevice device) async {
  _useScreenSize(tester);
  tester.testTextInput.register();
  addTearDown(tester.testTextInput.unregister);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: device.container,
      child: const SousviteApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// The screen size, in dp, given as `--dart-define=E2E_SCREEN_SIZE=320x568`.
/// CI runs the flows on `flutter-tester` at a phone and a tablet size. Web
/// and real devices leave it unset and use their own screen.
void _useScreenSize(WidgetTester tester) {
  const size = String.fromEnvironment('E2E_SCREEN_SIZE');
  if (size.isEmpty) return;
  final [width, height] = size.split('x').map(double.parse).toList();
  tester.view
    ..physicalSize = Size(width, height)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Taps the widget [finder] finds, after scrolling it into view, and waits
/// for the screen to settle.
Future<void> tapOn(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Scrolls the page until [finder] is on screen, down unless [up] is set.
/// A long page builds only what is on or near the screen, so on a phone a
/// section further down doesn't exist until you scroll to it, and one you
/// scrolled past is gone until you scroll back. Scrolls the page's first
/// scrollable: the only one on a phone, and with two panes the target is
/// usually built already.
Future<void> scrollTo(
  WidgetTester tester,
  Finder finder, {
  bool up = false,
}) async {
  await tester.scrollUntilVisible(
    finder,
    up ? -100 : 100,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}
