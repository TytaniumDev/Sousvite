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
        expect(DefaultFirebaseOptions.currentPlatform, isNull);
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
}
