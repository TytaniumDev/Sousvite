import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/services/auth_service.dart';
import 'package:sousvite/app/services/firebase.dart';
import 'package:sousvite/firebase_options.dart';

void main() {
  group('firebase', () {
    test(
      'without config, Firebase stays off and the app is signed out',
      () async {
        expect(await initFirebase(null), isNull);

        final container = ProviderContainer.test();
        expect(container.read(firebaseAppProvider), isNull);
        expect(
          container.read(authServiceProvider),
          isA<SignedOutAuthService>(),
        );
      },
    );
  });

  group('DefaultFirebaseOptions', () {
    FirebaseOptions? on(TargetPlatform platform, {bool isWeb = false}) =>
        DefaultFirebaseOptions.forPlatform(isWeb: isWeb, platform: platform);

    test('picks the registered app for each platform', () {
      expect(on(.android), DefaultFirebaseOptions.android);
      expect(on(.iOS), DefaultFirebaseOptions.ios);
      expect(on(.android, isWeb: true), DefaultFirebaseOptions.web);
      expect(
        DefaultFirebaseOptions.currentPlatform,
        DefaultFirebaseOptions.android,
      );
    });

    test('has no config on desktop, which runs signed out', () {
      for (final platform in [
        TargetPlatform.fuchsia,
        TargetPlatform.linux,
        TargetPlatform.macOS,
        TargetPlatform.windows,
      ]) {
        expect(on(platform), isNull, reason: '$platform');
      }
    });

    test('every app is in the sousvite project', () {
      for (final options in [
        DefaultFirebaseOptions.android,
        DefaultFirebaseOptions.ios,
        DefaultFirebaseOptions.web,
      ]) {
        expect(options.projectId, 'sousvite');
        expect(options.appId, startsWith('1:761600243200:'));
      }
      expect(
        DefaultFirebaseOptions.ios.iosBundleId,
        'com.tytaniumdev.sousvite',
      );
    });
  });
}
