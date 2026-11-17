import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:sousvite/app/providers/database.dart';
import 'package:sousvite/app/services/error_reporter.dart';
import 'package:sousvite/app/services/firebase.dart';
import 'package:sousvite/firebase_options.dart';

/// Starts the app: sets up error reporting, then runs [builder] inside the
/// app's [ProviderContainer].
///
/// Setup that must happen before the first frame (Sentry, Firebase,
/// RevenueCat) goes here, behind the service interfaces in `app/services/`.
Future<void> bootstrap(Widget Function() builder) async {
  // Web addresses without a `#`, so links such as invite links
  // (`/invite/<id>`) open the right screen. Hosting serves index.html for
  // every path. Does nothing on other platforms.
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  final firebase = await initFirebase(DefaultFirebaseOptions.currentPlatform);
  final container = ProviderContainer(
    overrides: [firebaseAppProvider.overrideWithValue(firebase)],
  );
  await initErrorReporting(container.read(sentryDsnProvider));
  // After Sentry starts, so these handlers replace Sentry's own and every
  // error takes the one path through ErrorReporter.
  installErrorHandlers(container.read(errorReporterProvider));
  // Repositories read the recorder synchronously once it has loaded.
  await container.read(changeRecorderProvider.future);
  runApp(UncontrolledProviderScope(container: container, child: builder()));
}

/// Sends framework and uncaught asynchronous errors to [reporter].
@visibleForTesting
void installErrorHandlers(ErrorReporter reporter) {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    unawaited(
      reporter.report(details.exception, details.stack ?? StackTrace.empty),
    );
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    unawaited(reporter.report(error, stackTrace));
    return true;
  };
}
