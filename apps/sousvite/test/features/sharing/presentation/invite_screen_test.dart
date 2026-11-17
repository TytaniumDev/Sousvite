import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/app/services/auth_service.dart';
import 'package:sousvite/app/services/sharing_service.dart';
import 'package:sousvite/features/recipe/recipe.dart';
import 'package:sousvite/features/sharing/sharing.dart';

import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';
import '../../../helpers/helpers.dart';
import '../../account/fakes.dart';
import '../fakes.dart';

void main() {
  group('InviteScreen', () {
    late FakeSharingService sharing;
    late FakeRecipeRepository recipes;
    late GoRouter router;

    setUp(() {
      sharing = FakeSharingService();
      recipes = FakeRecipeRepository();
      router = GoRouter(
        initialLocation: SharingRoutes.inviteLocation('i1'),
        routes: [
          ...SharingRoutes.routes,
          GoRoute(
            path: RecipeRoutes.path,
            builder: (context, state) =>
                Text('Recipe ${state.pathParameters['recipeId']}'),
          ),
        ],
      );
      addTearDown(router.dispose);
    });

    Future<void> pump(WidgetTester tester, {bool signedIn = true}) async {
      await tester.pumpRouterApp(
        router,
        overrides: [
          authServiceProvider.overrideWithValue(
            FakeAuthService(signedIn ? tyler : null),
          ),
          sharingServiceProvider.overrideWithValue(sharing),
          recipeRepositoryProvider.overrideWithValue(recipes),
        ],
      );
      await tester.pumpAndSettle();
    }

    testWidgets('asks signed-out users to sign in', (tester) async {
      await pump(tester, signedIn: false);

      expect(
        find.text('Sign in to add this recipe to your library.'),
        findsOneWidget,
      );
    });

    testWidgets('adds a sent copy and opens it', (tester) async {
      sharing.accepted = AcceptedCopy(
        title: 'Oat pancakes',
        entities: const RecipeSnapshotCodec().encode(
          RecipeSnapshot(recipe: RecipeFixtures.recipe()),
        ),
      );
      await pump(tester);

      expect(
        find.text('Alice sent you a copy of Oat pancakes'),
        findsOneWidget,
      );
      await tester.tap(find.text('Add to my recipes'));
      await tester.pumpAndSettle();

      final saved = await recipes.watchRecipeIds().first;
      expect(saved, hasLength(1));
      expect(find.text('Recipe ${saved.single.value}'), findsOneWidget);
    });

    testWidgets('names no sender when the sign-in had no name', (tester) async {
      sharing.preview = const InvitePreview(kind: .copy, title: 'Soup');
      await pump(tester);

      expect(find.text('You were sent a copy of Soup'), findsOneWidget);
    });

    testWidgets('says when adding the copy fails', (tester) async {
      await pump(tester);
      sharing.error = const SharingFailure(.unavailable);

      await tester.tap(find.text('Add to my recipes'));
      await tester.pumpAndSettle();

      expect(
        find.text("Couldn't share. Check your connection and try again."),
        findsOneWidget,
      );
    });

    testWidgets('explains joint invites are not ready yet', (tester) async {
      sharing.preview = const InvitePreview(
        kind: .joint,
        title: 'Soup',
        fromName: 'Alice',
      );
      await pump(tester);

      expect(find.text('Alice invited you to share Soup'), findsOneWidget);
      expect(find.text('Add to my recipes'), findsNothing);

      sharing.preview = const InvitePreview(kind: .joint, title: 'Soup');
    });

    testWidgets('says when the link no longer works', (tester) async {
      sharing.error = const SharingFailure(.expired);
      await pump(tester);

      expect(find.text('This link no longer works'), findsOneWidget);
    });
  });
}
