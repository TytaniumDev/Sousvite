import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/services/auth_service.dart';
import 'package:sousvite/features/account/presentation/account_screen.dart';
import 'package:sousvite/features/account/presentation/delete_account_button.dart';
import 'package:sousvite/features/account/presentation/sign_in_view.dart';
import 'package:sousvite/features/account/presentation/signed_in_view.dart';

import '../../../helpers/helpers.dart';
import '../fakes.dart';

void main() {
  Future<FakeAuthService> pumpScreen(
    WidgetTester tester, [
    AuthUser? user,
  ]) async {
    final auth = FakeAuthService(user);
    await tester.pumpApp(
      const AccountScreen(),
      overrides: [authServiceProvider.overrideWithValue(auth)],
    );
    await tester.pump();
    return auth;
  }

  group(AccountScreen, () {
    testWidgets('keeps sign-in to a narrow column on a wide window', (
      tester,
    ) async {
      tester.setWindowWidth(1600);
      await pumpScreen(tester);

      tester
        ..expectInCenteredColumn(
          find.byType(FilledButton),
          ReadingColumn.formWidth,
        )
        ..expectInCenteredColumn(
          find.descendant(
            of: find.byType(SignInView),
            matching: find.byType(Text),
          ),
          ReadingColumn.formWidth,
        );
    });

    testWidgets('offers Google and Apple when signed out', (tester) async {
      await pumpScreen(tester);

      expect(find.byType(SignInView), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('Sign in with Apple'), findsOneWidget);
    });

    testWidgets('signing in shows the account', (tester) async {
      final auth = await pumpScreen(tester);

      await tester.tap(find.text('Sign in with Apple'));
      await tester.pump();
      await tester.pump();

      expect(auth.calls, ['apple']);
      expect(find.byType(SignedInView), findsOneWidget);
      expect(find.text('Tyler'), findsOneWidget);
      expect(
        find.text('tyler@example.com\nSigned in with Google'),
        findsOneWidget,
      );
    });

    testWidgets('disables the buttons while an action runs', (tester) async {
      final auth = await pumpScreen(tester);
      final gate = auth.gate = Completer<void>();

      await tester.tap(find.text('Sign in with Google'));
      await tester.pump();

      final apple = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Sign in with Apple'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(apple.onPressed, isNull);

      gate.complete();
      await tester.pump();
    });

    testWidgets('shows an error when sign-in fails', (tester) async {
      final auth = await pumpScreen(tester)
        ..error = const AuthFailure('offline');

      await tester.tap(find.text('Sign in with Google'));
      await tester.pump();

      expect(
        find.text(
          "Couldn't reach your account. Check your connection and try again.",
        ),
        findsOneWidget,
      );
      expect(auth.calls, ['google']);
    });

    testWidgets('names an account without a name by its email or a label', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const AuthUser(id: 'u2', email: 'a@example.com', method: .apple),
      );
      expect(find.text('a@example.com'), findsOneWidget);
      expect(find.text('Signed in with Apple'), findsOneWidget);
    });

    testWidgets('labels an account with no name, email, or method', (
      tester,
    ) async {
      await pumpScreen(tester, const AuthUser(id: 'u3'));

      expect(find.text('Your account'), findsOneWidget);
      expect(find.text('Signed in'), findsOneWidget);
    });

    testWidgets('signing out shows the sign-in buttons again', (tester) async {
      final auth = await pumpScreen(tester, tyler);

      await tester.tap(find.text('Sign out'));
      await tester.pump();
      await tester.pump();

      expect(auth.calls, ['signOut']);
      expect(find.byType(SignInView), findsOneWidget);
    });

    testWidgets('a busy action rebuilds the buttons, not the account', (
      tester,
    ) async {
      final auth = await pumpScreen(tester, tyler);
      final gate = auth.gate = Completer<void>();
      final builds = BuildCounter.start();

      await tester.tap(find.text('Sign out'));
      await tester.pump();

      expect(builds.of<DeleteAccountButton>(), 1);
      expect(builds.of<AccountScreen>(), 0);
      expect(builds.of<SignedInView>(), 0);

      gate.complete();
      await tester.pump();
    });
  });

  group(DeleteAccountButton, () {
    Future<void> openDialog(WidgetTester tester) async {
      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
    }

    testWidgets('does nothing when the user cancels', (tester) async {
      final auth = await pumpScreen(tester, tyler);

      await openDialog(tester);
      expect(find.text('Delete your account?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(auth.calls, isEmpty);
      expect(find.byType(SignedInView), findsOneWidget);
    });

    testWidgets('deletes after confirming and says so', (tester) async {
      final auth = await pumpScreen(tester, tyler);

      await openDialog(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Delete account'),
        ),
      );
      await tester.pumpAndSettle();

      expect(auth.calls, ['delete']);
      expect(find.text('Account deleted'), findsOneWidget);
      expect(find.byType(SignInView), findsOneWidget);
    });

    testWidgets('says nothing when confirming with Apple is canceled', (
      tester,
    ) async {
      final auth = await pumpScreen(tester, tyler)
        ..outcome = .canceled;

      await openDialog(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Delete account'),
        ),
      );
      await tester.pumpAndSettle();

      expect(auth.calls, ['delete']);
      expect(find.text('Account deleted'), findsNothing);
      expect(find.byType(SignedInView), findsOneWidget);
    });
  });
}
