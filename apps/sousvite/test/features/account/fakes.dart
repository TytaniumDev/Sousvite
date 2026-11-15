import 'dart:async';

import 'package:sousvite/app/services/auth_service.dart';

/// The user the fake signs in as.
const tyler = AuthUser(
  id: 'u1',
  displayName: 'Tyler',
  email: 'tyler@example.com',
  method: SignInMethod.google,
);

/// An [AuthService] in memory. Set [outcome] or [error] to choose how the
/// next action ends.
class FakeAuthService([AuthUser? initialUser]) implements AuthService {
  var _user = initialUser;
  final _changes = StreamController<AuthUser?>.broadcast();

  /// How actions end when [error] is null.
  AuthOutcome outcome = .completed;

  /// Thrown by the next actions, when set.
  Exception? error;

  /// The actions called, in order.
  final calls = <String>[];

  /// Completes actions when set, so tests can see the busy state.
  Completer<void>? gate;

  @override
  Stream<AuthUser?> watchUser() async* {
    yield _user;
    yield* _changes.stream;
  }

  Future<AuthOutcome> _act(String name, AuthUser? userAfter) async {
    calls.add(name);
    await gate?.future;
    if (error case final error?) throw error;
    if (outcome == .completed) {
      _user = userAfter;
      _changes.add(userAfter);
    }
    return outcome;
  }

  @override
  Future<AuthOutcome> signInWithGoogle() => _act('google', tyler);

  @override
  Future<AuthOutcome> signInWithApple() => _act('apple', tyler);

  @override
  Future<void> signOut() => _act('signOut', null);

  @override
  Future<AuthOutcome> deleteAccount() => _act('delete', null);
}
