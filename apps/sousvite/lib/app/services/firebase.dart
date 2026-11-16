import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/services/app_check.dart';

part 'firebase.g.dart';

/// The started Firebase app, or null when this build has no Firebase
/// config, as in tests. `bootstrap` overrides it with the app [initFirebase]
/// started.
@Riverpod(keepAlive: true)
FirebaseApp? firebaseApp(Ref ref) => null;

/// Starts Firebase with [options] and turns on App Check, or returns null
/// without them, so a build without Firebase config still runs, signed out.
Future<FirebaseApp?> initFirebase(FirebaseOptions? options) async {
  if (options == null) return null;
  final app = await Firebase.initializeApp(options: options);
  await activateAppCheck(
    FirebaseAppCheck.instanceFor(app: app),
    debug: kDebugMode,
  );
  return app;
}
