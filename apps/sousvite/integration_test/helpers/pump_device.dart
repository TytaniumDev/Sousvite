import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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

/// Taps the widget [finder] finds, after scrolling it into view, and waits
/// for the screen to settle.
Future<void> tapOn(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
