import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/account/account_routes.dart';
import 'package:sousvite/features/account/sync/application/sign_in_callout.dart';
import 'package:sousvite/features/account/sync/presentation/sign_in_callout_card.dart';

import '../../../../helpers/helpers.dart';

class _Dismissal(final List<DateTime> dismissals)
    extends SignInCalloutDismissal {
  @override
  Future<DateTime?> build() async => null;

  @override
  Future<void> dismiss() async => dismissals.add(DateTime(2026));
}

void main() {
  Future<List<DateTime>> pump(
    WidgetTester tester,
    Widget widget, {
    bool invited = true,
  }) async {
    final dismissals = <DateTime>[];
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(body: ListView(children: [widget])),
        ),
        GoRoute(
          path: AccountRoutes.path,
          builder: (_, _) => const Text('account'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpRouterApp(
      router,
      overrides: [
        signInInviteAvailableProvider.overrideWithValue(invited),
        signInCalloutVisibleProvider.overrideWithValue(invited),
        signInCalloutDismissalProvider.overrideWith(
          () => _Dismissal(dismissals),
        ),
      ],
    );
    await tester.pump();
    return dismissals;
  }

  group(SignInCalloutCard, () {
    testWidgets('is hidden when not invited', (tester) async {
      await pump(tester, const SignInCalloutCard(), invited: false);

      expect(find.text('Not now'), findsNothing);
    });

    testWidgets('"Not now" dismisses it', (tester) async {
      final dismissals = await pump(tester, const SignInCalloutCard());

      await tester.tap(find.text('Not now'));
      await tester.pump();

      expect(dismissals, hasLength(1));
    });

    testWidgets('"Sign in" opens the account screen', (tester) async {
      await pump(tester, const SignInCalloutCard());

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('account'), findsOneWidget);
    });
  });

  group(SignInCalloutTile, () {
    testWidgets('is hidden when not invited', (tester) async {
      await pump(tester, const SignInCalloutTile(), invited: false);

      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('opens the account screen', (tester) async {
      await pump(tester, const SignInCalloutTile());

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      expect(find.text('account'), findsOneWidget);
    });
  });
}
