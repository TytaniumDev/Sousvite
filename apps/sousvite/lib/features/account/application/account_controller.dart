import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/services/auth_service.dart';

part 'account_controller.g.dart';

/// Runs one account action at a time. The state is loading while an action
/// runs, then the outcome of the last one, or its error.
@riverpod
class AccountController() extends _$AccountController {
  @override
  FutureOr<AuthOutcome?> build() => null;

  Future<AuthOutcome?> signInWithGoogle() =>
      _run((auth) => auth.signInWithGoogle());

  Future<AuthOutcome?> signInWithApple() =>
      _run((auth) => auth.signInWithApple());

  Future<AuthOutcome?> signOut() => _run((auth) async {
    await auth.signOut();
    return .completed;
  });

  Future<AuthOutcome?> deleteAccount() => _run((auth) => auth.deleteAccount());

  Future<AuthOutcome?> _run(
    Future<AuthOutcome> Function(AuthService auth) action,
  ) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => action(ref.read(authServiceProvider)),
    );
    if (ref.mounted) state = result;
    return result.value;
  }
}
