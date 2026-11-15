import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/services/auth_service.dart';
import 'package:sousvite/features/account/account.dart';
import 'package:sousvite/features/account/application/account_controller.dart';

import '../fakes.dart';

void main() {
  late FakeAuthService auth;
  late ProviderContainer container;

  setUp(() {
    auth = FakeAuthService();
    container = ProviderContainer.test(
      overrides: [authServiceProvider.overrideWithValue(auth)],
    )..listen(accountControllerProvider, (_, _) {});
  });

  AccountController controller() =>
      container.read(accountControllerProvider.notifier);

  group(AccountController, () {
    test('signs in with Google or Apple and reports the outcome', () async {
      expect(await controller().signInWithGoogle(), AuthOutcome.completed);
      expect(await controller().signInWithApple(), AuthOutcome.completed);

      expect(auth.calls, ['google', 'apple']);
      expect(
        container.read(accountControllerProvider).value,
        AuthOutcome.completed,
      );
    });

    test('signs out and deletes the account', () async {
      expect(await controller().signOut(), AuthOutcome.completed);
      expect(await controller().deleteAccount(), AuthOutcome.completed);

      expect(auth.calls, ['signOut', 'delete']);
    });

    test('keeps a failure as an error state', () async {
      auth.error = const AuthFailure('offline');

      expect(await controller().signInWithGoogle(), isNull);

      expect(container.read(accountControllerProvider).hasError, isTrue);
    });
  });

  group('authUserProvider', () {
    test('follows the signed-in user', () async {
      final user = container.listen(authUserProvider, (_, _) {});
      await container.pump();
      expect(user.read().value, isNull);

      await controller().signInWithGoogle();
      await container.pump();

      expect(user.read().value, tyler);
    });
  });
}
