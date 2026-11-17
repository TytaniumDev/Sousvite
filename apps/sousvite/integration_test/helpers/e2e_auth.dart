import 'package:sousvite/app/services/auth_service.dart';

/// Always signed in as [_user]; nothing in the end-to-end flows signs out.
class const E2eAuth(final AuthUser _user) implements AuthService {
  @override
  Stream<AuthUser?> watchUser() => Stream.value(_user);

  @override
  Future<AuthOutcome> signInWithGoogle() async => .completed;

  @override
  Future<AuthOutcome> signInWithApple() async => .completed;

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthOutcome> deleteAccount() async => .completed;
}

/// The two people in the end-to-end flows.
const alice = AuthUser(
  id: 'alice',
  displayName: 'Alice',
  email: 'alice@example.com',
  method: SignInMethod.google,
);

const bob = AuthUser(
  id: 'bob',
  displayName: 'Bob',
  email: 'bob@example.com',
  method: SignInMethod.google,
);
