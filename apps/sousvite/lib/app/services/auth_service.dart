import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/services/firebase.dart';
import 'package:sousvite/app/services/firebase_auth_service.dart';
import 'package:sousvite/firebase_options.dart';

part 'auth_service.g.dart';

/// How a user signed in (PRD 7.9).
enum SignInMethod() {
  google,
  apple,
}

/// A signed-in user. Signing in is optional (ENGINEERING.md §10).
@immutable
class const AuthUser({
  required final String id,
  final String? displayName,
  final String? email,

  /// Null when the account uses neither Google nor Apple, which the app
  /// never creates.
  final SignInMethod? method,
}) {
  @override
  bool operator ==(Object other) =>
      other is AuthUser &&
      other.id == id &&
      other.displayName == displayName &&
      other.email == email &&
      other.method == method;

  @override
  int get hashCode => Object.hash(id, displayName, email, method);
}

/// How an account action the user can back out of ended.
enum AuthOutcome() {
  completed,

  /// The user closed the Google or Apple sheet.
  canceled,
}

/// An account action that failed for a reason other than the user
/// canceling, such as no connection.
class const AuthFailure(
  /// What went wrong underneath, for error reports.
  final Object cause,
) implements Exception {
  @override
  String toString() => 'AuthFailure: $cause';
}

/// Google and Apple sign-in, sign-out, and account deletion.
///
/// [FirebaseAuthService] when the build has Firebase config, otherwise
/// [SignedOutAuthService].
abstract interface class AuthService() {
  /// The current user, or null when signed out.
  Stream<AuthUser?> watchUser();

  /// Throws [AuthFailure] when sign-in fails.
  Future<AuthOutcome> signInWithGoogle();

  /// Throws [AuthFailure] when sign-in fails.
  Future<AuthOutcome> signInWithApple();

  /// Signs out on this device. Local recipes stay.
  Future<void> signOut();

  /// Deletes the account and everything stored for it on the server, then
  /// signs out (PRD 7.9). Local recipes stay. Throws [AuthFailure] when it
  /// fails.
  Future<AuthOutcome> deleteAccount();
}

/// Always signed out, for builds without Firebase config. Sign-in reports
/// that it is not available.
class const SignedOutAuthService() implements AuthService {
  @override
  Stream<AuthUser?> watchUser() => Stream.value(null);

  @override
  Future<AuthOutcome> signInWithGoogle() =>
      Future.error(AuthFailure(UnsupportedError('Firebase is not set up.')));

  @override
  Future<AuthOutcome> signInWithApple() =>
      Future.error(AuthFailure(UnsupportedError('Firebase is not set up.')));

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthOutcome> deleteAccount() async => .completed;
}

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  final app = ref.watch(firebaseAppProvider);
  if (app == null) return const SignedOutAuthService();
  return FirebaseAuthService(
    auth: FirebaseAuth.instanceFor(app: app),
    functions: FirebaseFunctions.instanceFor(app: app, region: 'us-central1'),
    google: GoogleSignIn.instance,
    googleClientId: app.options.iosClientId,
    googleServerClientId: DefaultFirebaseOptions.googleServerClientId,
    isWeb: kIsWeb,
    platform: defaultTargetPlatform,
  );
}
