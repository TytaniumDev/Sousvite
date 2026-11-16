import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/app/services/auth_service.dart';
import 'package:sousvite/app/services/entitlements.dart';
import 'package:sousvite/app/services/error_reporter.dart';
import 'package:sousvite/app/services/nutrition_api.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer.test());

  group('stub services', () {
    test('auth is always signed out', () async {
      final auth = container.read(authServiceProvider);

      expect(await auth.watchUser().first, isNull);
      await expectLater(auth.signInWithGoogle(), throwsA(isA<AuthFailure>()));
      await expectLater(auth.signInWithApple(), throwsA(isA<AuthFailure>()));
      await auth.signOut();
      expect(await auth.deleteAccount(), AuthOutcome.completed);
    });

    test('entitlements are never Pro', () async {
      expect(
        await container.read(entitlementsProvider).watchIsPro().first,
        isFalse,
      );
    });

    test('the offline nutrition API finds nothing', () async {
      const api = OfflineNutritionApi();

      expect(await api.search('oats'), isEmpty);
      expect(await api.lookupBarcode('0123'), isNull);
    });

    test(
      'the nutrition API goes online, without USDA when Firebase is off',
      () {
        expect(container.read(nutritionApiProvider), isA<OnlineNutritionApi>());
      },
    );

    test('the error reporter prints to the console', () async {
      final printed = <String?>[];
      final previous = debugPrint;
      debugPrint = (message, {wrapWidth}) => printed.add(message);
      addTearDown(() => debugPrint = previous);

      await container
          .read(errorReporterProvider)
          .report(StateError('boom'), StackTrace.empty);

      expect(printed.single, contains('boom'));
    });
  });

  group(AuthUser, () {
    test('has value equality', () {
      const user = AuthUser(id: '1', displayName: 'Tyler');

      expect(user, const AuthUser(id: '1', displayName: 'Tyler'));
      expect(
        user.hashCode,
        const AuthUser(id: '1', displayName: 'Tyler').hashCode,
      );
      expect(user, isNot(const AuthUser(id: '2')));
      expect(
        user,
        isNot(
          const AuthUser(
            id: '1',
            displayName: 'Tyler',
            method: SignInMethod.apple,
          ),
        ),
      );
    });

    test('AuthFailure names its cause', () {
      expect('${AuthFailure(StateError('offline'))}', contains('offline'));
    });
  });

  group('repository providers', () {
    test('throw until a data task implements them', () {
      for (final provider in <ProviderListenable<Object>>[
        foodRepositoryProvider,
      ]) {
        expect(() => container.read(provider), throwsA(anything));
      }
    });
  });
}
