import 'package:google_sign_in/google_sign_in.dart';

/// The OAuth scope for the hidden Drive app folder, the only Drive access
/// Sousvite asks for (ENGINEERING.md §10).
const driveAppDataScope = 'https://www.googleapis.com/auth/drive.appdata';

/// Drive needs the user to tap through Google again, such as when a web
/// token expired and Google can't renew it silently. Sync pauses and shows
/// "Sign in again" instead of interrupting with a popup (ENGINEERING.md
/// §8.2).
final class const DriveSignInRequired() implements Exception {
  @override
  String toString() => 'DriveSignInRequired';
}

/// Access tokens for the Drive app folder.
abstract interface class DriveAccess() {
  /// A current access token, renewed silently when it can be. Throws
  /// [DriveSignInRequired] when the user has to tap through Google.
  Future<String> token();

  /// Forgets [token], after Drive rejected it, so the next [token] is new.
  Future<void> discard(String token);

  /// Asks the user to allow Drive access, with Google's own sheet or popup.
  /// Call it only from a tap.
  Future<void> request();
}

/// [DriveAccess] through Google sign-in's authorization client.
final class GoogleDriveAccess(
  /// Google sign-in, already initialized by the auth service.
  final GoogleSignIn google,
) implements DriveAccess {
  static const List<String> _scopes = [driveAppDataScope];

  @override
  Future<String> token() async {
    final authorization = await google.authorizationClient
        .authorizationForScopes(_scopes);
    if (authorization == null) throw const DriveSignInRequired();
    return authorization.accessToken;
  }

  @override
  Future<void> discard(String token) =>
      google.authorizationClient.clearAuthorizationToken(accessToken: token);

  @override
  Future<void> request() async {
    await google.authorizationClient.authorizeScopes(_scopes);
  }
}
