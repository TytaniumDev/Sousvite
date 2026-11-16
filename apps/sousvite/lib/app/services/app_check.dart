import 'package:firebase_app_check/firebase_app_check.dart';

/// The public reCAPTCHA Enterprise site key registered for the web app in
/// App Check, for sousvite.web.app and sousvite.firebaseapp.com.
const appCheckWebSiteKey = '6Lf3ayMuAAAAAHtuLp6wQCwt4gAX13EbY8tIfesN';

/// A debug token registered in the Firebase console (App Check → Apps →
/// Manage debug tokens), passed with
/// `--dart-define=APP_CHECK_DEBUG_TOKEN=...`, so every debug build shares
/// one token. Without it, each debug install logs a new token to register.
const appCheckDebugToken = String.fromEnvironment('APP_CHECK_DEBUG_TOKEN');

/// Turns on App Check, so the callable functions that enforce it (the fetch
/// and USDA proxies) accept this app's calls (ENGINEERING.md §9).
///
/// Release builds attest with App Attest on iOS, Play Integrity on Android,
/// and reCAPTCHA Enterprise on web. [debug] builds use the debug provider
/// on every platform, because local builds and emulators can't attest.
/// [debugToken] is the registered debug token, or empty to have the SDK
/// make one and log it.
Future<void> activateAppCheck(
  FirebaseAppCheck appCheck, {
  required bool debug,
  String debugToken = appCheckDebugToken,
}) {
  final token = debugToken.isEmpty ? null : debugToken;
  return appCheck.activate(
    providerWeb: debug
        ? WebDebugProvider(debugToken: token)
        : ReCaptchaEnterpriseProvider(appCheckWebSiteKey),
    providerAndroid: debug
        ? AndroidDebugProvider(debugToken: token)
        : const AndroidPlayIntegrityProvider(),
    providerApple: debug
        ? AppleDebugProvider(debugToken: token)
        : const AppleAppAttestProvider(),
  );
}
