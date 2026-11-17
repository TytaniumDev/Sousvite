import 'package:domain/domain.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/app/services/auth_service.dart';
import 'package:sousvite/app/services/sharing_service.dart';
import 'package:sousvite/features/sharing/presentation/sharing_screen.dart';

import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';
import '../../../helpers/helpers.dart';
import '../../account/fakes.dart';
import '../fakes.dart';

void main() {
  group(SharingScreen, () {
    late FakeSharingService sharing;
    late FakeRecipeRepository recipes;
    final copied = <String>[];

    setUp(() {
      sharing = FakeSharingService();
      recipes = FakeRecipeRepository()
        ..seed(
          recipe: RecipeFixtures.recipe(),
          lines: [RecipeFixtures.line('l1', rawText: '1 cup oats')],
        );
      copied.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              copied.add((call.arguments as Map)['text'] as String);
            }
            return null;
          });
    });

    Future<void> pump(WidgetTester tester, {bool signedIn = true}) =>
        tester.pumpApp(
          const SharingScreen(recipeId: RecipeId('r1')),
          overrides: [
            authServiceProvider.overrideWithValue(
              FakeAuthService(signedIn ? tyler : null),
            ),
            sharingServiceProvider.overrideWithValue(sharing),
            recipeRepositoryProvider.overrideWithValue(recipes),
          ],
        );

    testWidgets('asks signed-out users to sign in', (tester) async {
      await pump(tester, signedIn: false);
      await tester.pumpAndSettle();

      expect(find.text('Sign in to share'), findsOneWidget);
      expect(find.text('Send a copy'), findsNothing);
    });

    testWidgets('makes a copy link and copies it', (tester) async {
      await pump(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create copy link'));
      await tester.pumpAndSettle();

      expect(
        find.text('https://sousvite.web.app/invite/copy1'),
        findsOneWidget,
      );
      expect(sharing.sentEntities, isNotEmpty);

      await tester.tap(find.text('Copy link'));
      await tester.pumpAndSettle();
      expect(copied, ['https://sousvite.web.app/invite/copy1']);
      expect(find.text('Link copied'), findsOneWidget);
    });

    testWidgets('publishes a view-only link and turns it off', (tester) async {
      await pump(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create view-only link'));
      await tester.pumpAndSettle();

      expect(find.text('https://sousvite.web.app/r/link1'), findsOneWidget);
      // The amount and its word are joined by a no-break space.
      expect(
        sharing.publishedPage?.yieldText,
        matches(RegExp(r'^1\s+serving$')),
      );

      await tester.ensureVisible(find.text('Turn off link'));
      await tester.tap(find.text('Turn off link'));
      await tester.pumpAndSettle();

      expect(sharing.unpublished, ['link1']);
      expect(find.text('Link turned off'), findsOneWidget);
      expect(find.text('Create view-only link'), findsOneWidget);
    });

    testWidgets('says when sharing fails', (tester) async {
      sharing.error = const SharingFailure(.unavailable);
      await pump(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create copy link'));
      await tester.pumpAndSettle();

      expect(
        find.text("Couldn't share. Check your connection and try again."),
        findsOneWidget,
      );
      expect(find.text('Create copy link'), findsOneWidget);
    });
  });
}
