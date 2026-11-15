import 'package:firebase_core/firebase_core.dart';

/// Firebase config for each platform.
///
/// A stand-in until `flutterfire configure --project=sousvite` replaces this
/// file with the generated one (BUILD_PLAN.md §8.1). Until then there is no
/// config, so the app runs signed out.
abstract final class DefaultFirebaseOptions() {
  /// The options for the platform the app runs on.
  static FirebaseOptions? get currentPlatform => null;
}
