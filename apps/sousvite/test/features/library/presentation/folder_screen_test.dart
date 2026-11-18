import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/library/application/library_scope.dart';
import 'package:sousvite/features/library/library.dart';
import 'package:sousvite/features/library/presentation/folder_screen.dart';
import 'package:sousvite/features/library/presentation/library_recipe_card.dart';
import 'package:sousvite/features/library/presentation/library_screen.dart';
import 'package:sousvite/features/library/presentation/recipe_grid.dart';
import 'package:sousvite/shared/photos/photos.dart';
import 'package:sousvite/shared/photos/stored_photo_image.dart';

import '../../../helpers/fakes/fake_folder_repository.dart';
import '../../../helpers/fakes/fake_photo_store.dart';
import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';
import '../../../helpers/helpers.dart';

void main() {
  const breakfast = FolderId('breakfast');
  const breakfastScope = FolderRecipes(breakfast);
  late FakeRecipeRepository recipes;
  late FakeFolderRepository folders;
  late FakePhotoStore photos;

  setUp(() {
    photos = FakePhotoStore();
    recipes = FakeRecipeRepository()
      ..seed(
        recipe: RecipeFixtures.recipe(id: 'oats').copyWith(
          totalTime: const Duration(minutes: 90),
          photoRef: 'oats-photo',
        ),
      )
      ..seed(
        recipe: RecipeFixtures.recipe(
          id: 'soup',
          title: 'Tomato soup',
          createdAt: DateTime.utc(2027),
        ),
      )
      ..seed(
        recipe: RecipeFixtures.recipe(
          id: 'salad',
          title: 'Green salad',
          createdAt: DateTime.utc(2026),
        ),
      );
    folders = FakeFolderRepository()
      ..seed(
        Folder(
          id: breakfast,
          name: 'Breakfast',
          createdAt: RecipeFixtures.createdAt,
        ),
        [const RecipeId('oats'), const RecipeId('soup')],
      );
  });

  List<Override> overrides() => [
    recipeRepositoryProvider.overrideWithValue(recipes),
    folderRepositoryProvider.overrideWithValue(folders),
    photoStoreProvider.overrideWithValue(photos),
  ];

  Future<void> pumpFolder(
    WidgetTester tester, [
    LibraryScope scope = breakfastScope,
  ]) async {
    await tester.pumpApp(FolderScreen(scope: scope), overrides: overrides());
    await tester.pumpAndSettle();
  }

  group(FolderScreen, () {
    testWidgets("shows the folder's recipes newest first, with total time", (
      tester,
    ) async {
      await pumpFolder(tester);

      expect(find.widgetWithText(AppBar, 'Breakfast'), findsOneWidget);
      final cards = tester.widgetList<RecipeCard>(find.byType(RecipeCard));
      expect(cards.map((card) => card.title), ['Tomato soup', 'Oat pancakes']);
      expect(cards.first.image, isNull);
      expect(
        cards.last.image,
        isA<ResizeImage>().having(
          (i) => i.imageProvider,
          'photo',
          StoredPhotoImage(photos, 'oats-photo'),
        ),
      );
      expect(find.text('1 h 30 min'), findsOneWidget);
    });

    testWidgets('renaming a recipe rebuilds only its card', (tester) async {
      final builds = BuildCounter.start();
      await pumpFolder(tester);
      builds.reset();

      await recipes.saveRecipe(
        RecipeFixtures.recipe(
          id: 'soup',
          title: 'Roasted tomato soup',
          createdAt: DateTime.utc(2027),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Roasted tomato soup'), findsOneWidget);
      expect(builds.ofKey(const ValueKey(RecipeId('soup'))), 1);
      expect(builds.ofKey(const ValueKey(RecipeId('oats'))), 0);
      expect(builds.of<RecipeGrid>(), 0);
    });

    testWidgets('searches only this folder', (tester) async {
      await pumpFolder(tester);

      await tester.enterText(find.byType(SearchBar), 'tomato');
      await tester.pumpAndSettle();
      expect(find.byType(LibraryRecipeCard), findsOneWidget);

      await tester.enterText(find.byType(SearchBar), 'salad');
      await tester.pumpAndSettle();
      expect(find.text('No matching recipes'), findsOneWidget);
    });

    testWidgets('shows an empty folder', (tester) async {
      await folders.saveFolder(
        Folder(
          id: const FolderId('empty'),
          name: 'Desserts',
          createdAt: RecipeFixtures.createdAt,
        ),
      );
      await pumpFolder(tester, const FolderRecipes(FolderId('empty')));

      expect(find.text('Nothing in this folder yet'), findsOneWidget);
    });

    testWidgets('shows an error with a retry button', (tester) async {
      await tester.pumpApp(
        const FolderScreen(scope: breakfastScope),
        overrides: [folderRepositoryProvider.overrideWithValue(folders)],
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorState), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorState), findsOneWidget);
    });

    testWidgets('the unsorted page lists recipes in no folder', (tester) async {
      await pumpFolder(tester, const UnsortedRecipes());

      expect(find.widgetWithText(AppBar, 'Unsorted'), findsOneWidget);
      expect(find.byType(LibraryRecipeCard), findsOneWidget);
      expect(find.text('Green salad'), findsOneWidget);
      expect(find.byTooltip('Folder options'), findsNothing);
    });

    testWidgets('renames the folder', (tester) async {
      await pumpFolder(tester);

      await tester.tap(find.byTooltip('Folder options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename folder'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Mornings');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Mornings'), findsOneWidget);
    });

    Future<GoRouter> pumpFolderRoute(WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: LibraryRoutes.location(breakfastScope),
        routes: LibraryRoutes.routes,
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router, overrides: overrides());
      await tester.pumpAndSettle();
      return router;
    }

    Future<void> tapDelete(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Folder options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete folder'));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'deleting asks first, takes its only-here recipes, and undo restores',
      (tester) async {
        await pumpFolderRoute(tester);

        await tapDelete(tester);
        expect(find.text('Delete Breakfast?'), findsOneWidget);
        expect(
          find.text(
            '2 recipes are in no other folder and will be deleted too.',
          ),
          findsOneWidget,
        );
        await tester.tap(find.widgetWithText(TextButton, 'Delete'));
        await tester.pumpAndSettle();

        expect(find.byType(LibraryScreen), findsOneWidget);
        expect(find.byType(FolderScreen), findsNothing);
        expect(find.text('Breakfast'), findsNothing);
        expect(find.text('Folder and 2 recipes deleted'), findsOneWidget);
        expect(recipes.recipeById(const RecipeId('oats')), isNull);
        expect(recipes.recipeById(const RecipeId('salad')), isNotNull);

        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();
        expect(find.text('Breakfast'), findsOneWidget);
        expect(recipes.recipeById(const RecipeId('oats')), isNotNull);
        expect(folders.recipeIdsIn(breakfast), [
          const RecipeId('oats'),
          const RecipeId('soup'),
        ]);
      },
    );

    testWidgets('cancelling the delete keeps everything', (tester) async {
      await pumpFolderRoute(tester);

      await tapDelete(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(FolderScreen), findsOneWidget);
      expect(folders.allFolders, hasLength(1));
      expect(recipes.recipeById(const RecipeId('oats')), isNotNull);
    });

    testWidgets(
      'a folder whose recipes are all elsewhere goes without asking',
      (tester) async {
        folders.seed(
          Folder(
            id: const FolderId('mornings'),
            name: 'Mornings',
            createdAt: RecipeFixtures.createdAt,
          ),
          [const RecipeId('oats'), const RecipeId('soup')],
        );
        await pumpFolderRoute(tester);

        await tapDelete(tester);

        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('Folder deleted'), findsOneWidget);
        expect(recipes.recipeById(const RecipeId('oats')), isNotNull);
      },
    );

    testWidgets('a folder page adds recipes to that folder', (tester) async {
      await pumpFolder(tester);
      await tester.tap(find.text('Add recipe'));
      await tester.pumpAndSettle();
      expect(find.text('Add to which folder?'), findsNothing);
      expect(find.text('Write a recipe'), findsOneWidget);
    });

    testWidgets('the unsorted page has no add button', (tester) async {
      await pumpFolder(tester, const UnsortedRecipes());
      expect(find.text('Add recipe'), findsNothing);
    });

    testWidgets("a recipe's only folder can't be unticked", (tester) async {
      await pumpFolder(tester);

      await tester.longPress(find.text('Tomato soup'));
      await tester.pumpAndSettle();
      final only = find.widgetWithText(CheckboxListTile, 'Breakfast');
      expect(find.text('A recipe needs at least one folder'), findsOneWidget);
      expect(tester.widget<CheckboxListTile>(only).onChanged, isNull);

      await tester.tap(find.widgetWithText(ListTile, 'New folder'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Soups');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      expect(find.text('A recipe needs at least one folder'), findsNothing);

      await tester.tap(only);
      await tester.pumpAndSettle();
      expect(folders.recipeIdsIn(breakfast), [const RecipeId('oats')]);
    });

    testWidgets('puts a recipe in folders with a long press', (tester) async {
      await pumpFolder(tester, const UnsortedRecipes());

      await tester.longPress(find.text('Green salad'));
      await tester.pumpAndSettle();
      expect(find.text('Folders'), findsOneWidget);

      await tester.tap(find.widgetWithText(CheckboxListTile, 'Breakfast'));
      await tester.pumpAndSettle();
      expect(folders.recipeIdsIn(breakfast), contains(const RecipeId('salad')));

      await tester.tap(find.widgetWithText(ListTile, 'New folder'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Salads');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      final salads = folders.allFolders.firstWhere((f) => f.name == 'Salads');
      expect(folders.recipeIdsIn(salads.id), [const RecipeId('salad')]);
    });

    testWidgets('the folders sheet says when there are no folders', (
      tester,
    ) async {
      folders = FakeFolderRepository();
      await pumpFolder(tester, const UnsortedRecipes());

      await tester.longPress(find.text('Tomato soup'));
      await tester.pumpAndSettle();
      expect(
        find.text('No folders yet. Create one to sort your recipes.'),
        findsOneWidget,
      );
    });

    testWidgets('lays cards out in more columns on wide windows', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpFolder(tester);

      final first = tester.getTopLeft(find.byType(RecipeCard).first);
      final second = tester.getTopLeft(find.byType(RecipeCard).last);
      expect(first.dy, second.dy);
    });
  });
}
