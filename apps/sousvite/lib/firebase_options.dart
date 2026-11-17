import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase config for each platform, for the `sousvite` project
/// (BUILD_PLAN.md §8.1).
///
/// The same values `flutterfire configure --project=sousvite` writes, read
/// from the project's registered apps. None of them are secrets: App Check
/// and the security rules protect the backend.
abstract final class DefaultFirebaseOptions() {
  /// The options for the platform the app runs on, or null on a platform
  /// with no registered app (desktop), which then runs signed out.
  static FirebaseOptions? get currentPlatform =>
      forPlatform(isWeb: kIsWeb, platform: defaultTargetPlatform);

  /// The options for [platform], or for web when [isWeb].
  @visibleForTesting
  static FirebaseOptions? forPlatform({
    required bool isWeb,
    required TargetPlatform platform,
  }) {
    if (isWeb) return web;
    return switch (platform) {
      .android => android,
      .iOS => ios,
      .fuchsia || .linux || .macOS || .windows => null,
    };
  }

  /// The web app.
  static const web = FirebaseOptions(
    apiKey: 'AIzaSyCDrL1np9oASsLxHvpNPLhEVF-08letY4g',
    appId: '1:761600243200:web:c5183c2807a1587fbccae5',
    messagingSenderId: _senderId,
    projectId: _projectId,
    authDomain: 'sousvite.firebaseapp.com',
    storageBucket: _storageBucket,
  );

  /// The Android app.
  static const android = FirebaseOptions(
    apiKey: 'AIzaSyDRklajSRyw1NCq9xDBnUUJAVcX5Cxa2J4',
    appId: '1:761600243200:android:6cfe848832fd7fcdbccae5',
    messagingSenderId: _senderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
  );

  /// The iOS app.
  static const ios = FirebaseOptions(
    apiKey: 'AIzaSyDJksKISBGpMxu6gm8IuVPyhMC6v5b8jd4',
    appId: '1:761600243200:ios:234ce8766bc88e48bccae5',
    messagingSenderId: _senderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
    iosClientId:
        '761600243200-aokb4f0elf457vareepn1aaajha5qssr'
        '.apps.googleusercontent.com',
    iosBundleId: 'com.tytaniumdev.sousvite',
  );

  /// The project's web OAuth client. Native Google sign-in asks for an ID
  /// token for this client, which is the audience Firebase Auth accepts.
  /// Android needs it because the app doesn't ship `google-services.json`.
  static const googleServerClientId =
      '761600243200-20sp7ck7elc4tb5vmanp46dme2cf4gu6'
      '.apps.googleusercontent.com';

  static const _projectId = 'sousvite';
  static const _senderId = '761600243200';
  static const _storageBucket = 'sousvite.firebasestorage.app';
}
