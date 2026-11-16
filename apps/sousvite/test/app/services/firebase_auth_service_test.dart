import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sousvite/app/services/auth_service.dart';
import 'package:sousvite/app/services/firebase_auth_service.dart';

class _MockAuth() extends Mock implements FirebaseAuth;

class _MockFunctions() extends Mock implements FirebaseFunctions;

class _MockCallable() extends Mock implements HttpsCallable;

class _MockGoogle() extends Mock implements GoogleSignIn;

class _MockGoogleAccount() extends Mock implements GoogleSignInAccount;

class _MockUser() extends Mock implements User;

class _MockUserInfo() extends Mock implements UserInfo;

class _MockCredential() extends Mock implements UserCredential;

class _MockAdditionalInfo() extends Mock implements AdditionalUserInfo;

class _MockCallableResult() extends Mock implements HttpsCallableResult<void>;

void main() {
  late _MockAuth auth;
  late _MockFunctions functions;
  late _MockCallable callable;
  late _MockGoogle google;
  late _MockCredential credential;

  setUpAll(() {
    registerFallbackValue(GoogleAuthProvider());
    registerFallbackValue(AppleAuthProvider());
    registerFallbackValue(GoogleAuthProvider.credential(idToken: 'x'));
  });

  setUp(() {
    auth = _MockAuth();
    functions = _MockFunctions();
    callable = _MockCallable();
    google = _MockGoogle();
    credential = _MockCredential();
    when(
      () => google.initialize(
        clientId: any(named: 'clientId'),
        serverClientId: any(named: 'serverClientId'),
      ),
    ).thenAnswer((_) async {});
    when(() => google.signOut()).thenAnswer((_) async {});
    when(() => google.disconnect()).thenAnswer((_) async {});
    when(() => auth.signOut()).thenAnswer((_) async {});
    when(() => auth.signInWithPopup(any())).thenAnswer((_) async => credential);
    when(() => auth.signInWithProvider(any()))
        .thenAnswer((_) async => credential);
    when(() => auth.signInWithCredential(any()))
        .thenAnswer((_) async => credential);
    when(() => functions.httpsCallable(any())).thenReturn(callable);
    when(() => callable.call<void>())
        .thenAnswer((_) async => _MockCallableResult());
  });

  FirebaseAuthService service({
    bool isWeb = false,
    TargetPlatform platform = .android,
  }) => FirebaseAuthService(
    auth: auth,
    functions: functions,
    google: google,
    googleClientId: 'ios-client',
    googleServerClientId: 'web-client',
    isWeb: isWeb,
    platform: platform,
  );

  _MockUser userWith(String providerId) {
    final user = _MockUser();
    final info = _MockUserInfo();
    when(() => info.providerId).thenReturn(providerId);
    when(() => user.uid).thenReturn('u1');
    when(() => user.displayName).thenReturn('Tyler');
    when(() => user.email).thenReturn('tyler@example.com');
    when(() => user.providerData).thenReturn([info]);
    return user;
  }

  group('watchUser', () {
    test('maps Firebase users, with how they signed in', () async {
      when(() => auth.authStateChanges()).thenAnswer(
        (_) => Stream.fromIterable([
          null,
          userWith('google.com'),
          userWith('apple.com'),
          userWith('password'),
        ]),
      );

      expect(await service().watchUser().toList(), const [
        null,
        AuthUser(
          id: 'u1',
          displayName: 'Tyler',
          email: 'tyler@example.com',
          method: SignInMethod.google,
        ),
        AuthUser(
          id: 'u1',
          displayName: 'Tyler',
          email: 'tyler@example.com',
          method: SignInMethod.apple,
        ),
        AuthUser(id: 'u1', displayName: 'Tyler', email: 'tyler@example.com'),
      ]);
    });
  });

  group('signInWithGoogle', () {
    test('uses the native Google sheet on phones', () async {
      final account = _MockGoogleAccount();
      when(() => account.authentication)
          .thenReturn(const GoogleSignInAuthentication(idToken: 'id-token'));
      when(() => google.authenticate()).thenAnswer((_) async => account);

      expect(await service().signInWithGoogle(), AuthOutcome.completed);

      verify(
        () => google.initialize(
          clientId: 'ios-client',
          serverClientId: 'web-client',
        ),
      ).called(1);
      final signedInWith =
          verify(() => auth.signInWithCredential(captureAny())).captured.single
              as AuthCredential;
      expect(signedInWith.providerId, 'google.com');
    });

    test('uses a popup on web', () async {
      expect(
        await service(isWeb: true).signInWithGoogle(),
        AuthOutcome.completed,
      );

      verify(() => auth.signInWithPopup(any(that: isA<GoogleAuthProvider>())));
      verifyNever(() => google.authenticate());
    });

    test('reports closing the Google sheet as canceled', () async {
      when(() => google.authenticate()).thenThrow(
        const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
      );

      expect(await service().signInWithGoogle(), AuthOutcome.canceled);
    });

    test('wraps other Google errors', () async {
      when(() => google.authenticate()).thenThrow(
        const GoogleSignInException(
          code: GoogleSignInExceptionCode.clientConfigurationError,
        ),
      );

      await expectLater(
        service().signInWithGoogle(),
        throwsA(isA<AuthFailure>()),
      );
    });
  });

  group('signInWithApple', () {
    test('uses the provider flow on phones and a popup on web', () async {
      expect(await service().signInWithApple(), AuthOutcome.completed);
      verify(
        () => auth.signInWithProvider(any(that: isA<AppleAuthProvider>())),
      );

      expect(
        await service(isWeb: true).signInWithApple(),
        AuthOutcome.completed,
      );
      verify(() => auth.signInWithPopup(any(that: isA<AppleAuthProvider>())));
    });

    test('reports a closed sheet as canceled and wraps failures', () async {
      when(() => auth.signInWithProvider(any()))
          .thenThrow(FirebaseAuthException(code: 'web-context-canceled'));
      expect(await service().signInWithApple(), AuthOutcome.canceled);

      when(() => auth.signInWithProvider(any()))
          .thenThrow(FirebaseAuthException(code: 'network-request-failed'));
      await expectLater(
        service().signInWithApple(),
        throwsA(isA<AuthFailure>()),
      );
    });
  });

  group('signOut', () {
    test('signs out of Firebase and the Google sheet', () async {
      await service().signOut();

      verify(() => auth.signOut());
      verify(() => google.signOut());
    });

    test('skips the Google sheet on web', () async {
      await service(isWeb: true).signOut();

      verify(() => auth.signOut());
      verifyNever(() => google.signOut());
    });
  });

  group('deleteAccount', () {
    test('does nothing when signed out', () async {
      when(() => auth.currentUser).thenReturn(null);

      expect(await service().deleteAccount(), AuthOutcome.completed);
      verifyNever(() => functions.httpsCallable(any()));
    });

    test('deletes on the server, signs out, and disconnects Google', () async {
      final user = userWith('google.com');
      when(() => auth.currentUser).thenReturn(user);

      expect(await service().deleteAccount(), AuthOutcome.completed);

      verifyInOrder([
        () => functions.httpsCallable('deleteAccount'),
        () => callable.call<void>(),
        () => auth.signOut(),
        () => google.disconnect(),
      ]);
    });

    test('revokes the Apple token first on iOS', () async {
      final user = userWith('apple.com');
      final info = _MockAdditionalInfo();
      when(() => info.authorizationCode).thenReturn('code');
      when(() => credential.additionalUserInfo).thenReturn(info);
      when(() => user.reauthenticateWithProvider(any()))
          .thenAnswer((_) async => credential);
      when(() => auth.revokeTokenWithAuthorizationCode(any()))
          .thenAnswer((_) async {});
      when(() => auth.currentUser).thenReturn(user);

      expect(
        await service(platform: .iOS).deleteAccount(),
        AuthOutcome.completed,
      );

      verifyInOrder([
        () => auth.revokeTokenWithAuthorizationCode('code'),
        () => callable.call<void>(),
      ]);
      verifyNever(() => google.disconnect());
    });

    test('skips revoking Apple where Firebase cannot', () async {
      final user = userWith('apple.com');
      when(() => auth.currentUser).thenReturn(user);

      expect(await service().deleteAccount(), AuthOutcome.completed);

      verifyNever(() => user.reauthenticateWithProvider(any()));
      verify(() => callable.call<void>());
    });

    test('stops when the user cancels confirming with Apple', () async {
      final user = userWith('apple.com');
      when(() => user.reauthenticateWithProvider(any()))
          .thenThrow(FirebaseAuthException(code: 'canceled'));
      when(() => auth.currentUser).thenReturn(user);

      expect(
        await service(platform: .iOS).deleteAccount(),
        AuthOutcome.canceled,
      );
      verifyNever(() => callable.call<void>());
    });

    test('wraps server failures', () async {
      final user = userWith('google.com');
      when(() => auth.currentUser).thenReturn(user);
      when(() => callable.call<void>()).thenThrow(
        FirebaseFunctionsException(message: 'offline', code: 'unavailable'),
      );

      await expectLater(service().deleteAccount(), throwsA(isA<AuthFailure>()));
      verifyNever(() => auth.signOut());
    });
  });
}
