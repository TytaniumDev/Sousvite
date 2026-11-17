import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sousvite/app/services/auth_service.dart';

/// Firebase Auth error codes that mean the user closed the sign-in sheet or
/// popup rather than something failing.
const _canceledCodes = {
  'canceled',
  'cancelled-popup-request',
  'popup-closed-by-user',
  'user-cancelled',
  'web-context-canceled',
  'web-context-cancelled',
};

/// [AuthService] through Firebase Auth (ENGINEERING.md §9, §10).
///
/// Google uses the native Google sheet on iOS and Android and a popup on
/// web. Apple uses Firebase's provider flow, which is native on iOS and a
/// web sheet elsewhere.
class FirebaseAuthService({
  required final FirebaseAuth _auth,
  required final FirebaseFunctions _functions,
  required final GoogleSignIn _google,

  /// The OAuth client for the native Google sheet on iOS. Android and web
  /// don't use it.
  required final String? _googleClientId,

  /// The web OAuth client the native Google sheet asks for an ID token for,
  /// so Firebase Auth accepts the token. Android needs it; web doesn't use
  /// it.
  required final String? _googleServerClientId,

  /// Web signs in with popups instead of native sheets.
  required final bool _isWeb,
  required final TargetPlatform _platform,
}) implements AuthService {
  // Google sign-in must be initialized exactly once before use.
  late final Future<void> _googleReady = _google.initialize(
    clientId: _googleClientId,
    serverClientId: _googleServerClientId,
  );

  bool get _usesNativeGoogle => !_isWeb;

  // Apple asks apps to revoke the Sign in with Apple token when an account
  // is deleted. Firebase can do that only on Apple platforms.
  bool get _canRevokeApple =>
      !_isWeb && (_platform == .iOS || _platform == .macOS);

  @override
  Stream<AuthUser?> watchUser() => _auth.authStateChanges().map(_toAuthUser);

  @override
  Future<AuthOutcome> signInWithGoogle() => _guard(() async {
    if (!_usesNativeGoogle) {
      await _auth.signInWithPopup(GoogleAuthProvider());
      return;
    }
    await _googleReady;
    final account = await _google.authenticate();
    await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: account.authentication.idToken),
    );
  });

  @override
  Future<AuthOutcome> signInWithApple() => _guard(() async {
    final provider = _appleProvider();
    await (_isWeb
        ? _auth.signInWithPopup(provider)
        : _auth.signInWithProvider(provider));
  });

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    if (_usesNativeGoogle) {
      await _googleReady;
      await _google.signOut();
    }
  }

  @override
  Future<AuthOutcome> deleteAccount() => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final method = _methodOf(user);
    if (method == .apple && _canRevokeApple) {
      final credential = await user.reauthenticateWithProvider(
        _appleProvider(),
      );
      final code = credential.additionalUserInfo?.authorizationCode;
      if (code != null) await _auth.revokeTokenWithAuthorizationCode(code);
    }
    await _functions.httpsCallable('deleteAccount').call<void>();
    await _auth.signOut();
    if (method == .google && _usesNativeGoogle) {
      // Also removes Sousvite's access to the Google account, including
      // Drive.
      await _googleReady;
      await _google.disconnect();
    }
  });

  AppleAuthProvider _appleProvider() => AppleAuthProvider()
    ..addScope('email')
    ..addScope('name');

  /// Runs [action], turning a closed sign-in sheet into
  /// [AuthOutcome.canceled] and any other failure into [AuthFailure].
  Future<AuthOutcome> _guard(Future<void> Function() action) async {
    try {
      await action();
      return .completed;
    } on GoogleSignInException catch (error) {
      if (error.code == .canceled) return .canceled;
      throw AuthFailure(error);
    } on FirebaseAuthException catch (error) {
      if (_canceledCodes.contains(error.code)) return .canceled;
      throw AuthFailure(error);
    } on FirebaseFunctionsException catch (error) {
      throw AuthFailure(error);
    }
  }
}

AuthUser? _toAuthUser(User? user) => user == null
    ? null
    : AuthUser(
        id: user.uid,
        displayName: user.displayName,
        email: user.email,
        method: _methodOf(user),
      );

SignInMethod? _methodOf(User user) {
  for (final info in user.providerData) {
    switch (info.providerId) {
      case 'google.com':
        return .google;
      case 'apple.com':
        return .apple;
    }
  }
  return null;
}
