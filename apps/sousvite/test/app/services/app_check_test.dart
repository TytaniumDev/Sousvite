import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sousvite/app/services/app_check.dart';

class _MockAppCheck() extends Mock implements FirebaseAppCheck;

void main() {
  late _MockAppCheck appCheck;

  setUpAll(() {
    registerFallbackValue(WebDebugProvider());
    registerFallbackValue(const AndroidDebugProvider());
    registerFallbackValue(const AppleDebugProvider());
  });

  setUp(() {
    appCheck = _MockAppCheck();
    when(
      () => appCheck.activate(
        providerWeb: any(named: 'providerWeb'),
        providerAndroid: any(named: 'providerAndroid'),
        providerApple: any(named: 'providerApple'),
      ),
    ).thenAnswer((_) async {});
  });

  /// The Android, Apple, and web providers [activateAppCheck] chose, in
  /// the order mocktail captures named arguments (by name).
  List<Object?> activated() => verify(
    () => appCheck.activate(
      providerWeb: captureAny(named: 'providerWeb'),
      providerAndroid: captureAny(named: 'providerAndroid'),
      providerApple: captureAny(named: 'providerApple'),
    ),
  ).captured;

  group('activateAppCheck', () {
    test('attests with each platform provider in release builds', () async {
      await activateAppCheck(appCheck, debug: false);

      final [android, apple, web] = activated();
      expect(
        web,
        isA<ReCaptchaEnterpriseProvider>().having(
          (provider) => provider.siteKey,
          'siteKey',
          appCheckWebSiteKey,
        ),
      );
      expect(android, isA<AndroidPlayIntegrityProvider>());
      expect(apple, isA<AppleAppAttestProvider>());
    });

    test('uses the debug provider with the given token in debug', () async {
      await activateAppCheck(appCheck, debug: true, debugToken: 'token');

      final [android, apple, web] = activated();
      expect(
        web,
        isA<WebDebugProvider>().having((p) => p.debugToken, 'token', 'token'),
      );
      expect(
        android,
        isA<AndroidDebugProvider>().having(
          (p) => p.debugToken,
          'token',
          'token',
        ),
      );
      expect(
        apple,
        isA<AppleDebugProvider>().having((p) => p.debugToken, 'token', 'token'),
      );
    });

    test('lets the SDK make a debug token when none is given', () async {
      await activateAppCheck(appCheck, debug: true);

      final [android, apple, web] = activated();
      expect((web! as WebDebugProvider).debugToken, isNull);
      expect((android! as AndroidDebugProvider).debugToken, isNull);
      expect((apple! as AppleDebugProvider).debugToken, isNull);
    });
  });
}
