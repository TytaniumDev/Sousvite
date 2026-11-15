import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/library/presentation/folder_chips.dart';
import 'package:sousvite/features/library/presentation/library_recipe_card.dart';
import 'package:sousvite/features/library/presentation/library_screen.dart';
import 'package:sousvite/features/library/presentation/recipe_grid.dart';

import '../../../helpers/fakes/fake_folder_repository.dart';
import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';
import '../../../helpers/helpers.dart';

void main() {
  const breakfast = FolderId('breakfast');
  late FakeRecipeRepository recipes;
  late FakeFolderRepository folders;

  setUp(() {
    recipes = FakeRecipeRepository()
      ..seed(
        recipe: RecipeFixtures.recipe(id: 'oats')
            .copyWith(totalTime: const Duration(minutes: 90)),
      )
      ..seed(
        recipe: RecipeFixtures.recipe(
          id: 'soup',
          title: 'Tomato soup',
          createdAt: DateTime.utc(2027),
        ),
      );
    folders = FakeFolderRepository()
      ..seed(
        Folder(
          id: breakfast,
          name: 'Breakfast',
          createdAt: RecipeFixtures.createdAt,
        ),
        [const RecipeId('oats')],
      );
  });

  Future<void> pumpLibrary(WidgetTester tester) async {
    await tester.pumpApp(
      const LibraryScreen(),
      overrides: [
        recipeRepositoryProvider.overrideWithValue(recipes),
        folderRepositoryProvider.overrideWithValue(folders),
      ],
    );
    await tester.pumpAndSettle();
  }

  group(LibraryScreen, () {
    testWidgets('shows recipe cards newest first, with total time', (
      tester,
    ) async {
      await pumpLibrary(tester);

      final titles = tester
          .widgetList<RecipeCard>(find.byType(RecipeCard))
          .map((card) => card.title);
      expect(titles, ['Tomato soup', 'Oat pancakes']);
      expect(find.text('1 h 30 min'), findsOneWidget);
    });

    testWidgets('renaming a recipe rebuilds only its card', (tester) async {
      final builds = BuildCounter.start();
      await pumpLibrary(tester);
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
      expect(builds.of<FolderChips>(), 0);
    });

    testWidgets('filters by search', (tester) async {
      await pumpLibrary(tester);

      await tester.enterText(find.byType(SearchBar), 'tomato');
      await tester.pumpAndSettle();
      expect(find.byType(LibraryRecipeCard), findsOneWidget);

      await tester.enterText(find.byType(SearchBar), 'waffles');
      await tester.pumpAndSettle();
      expect(find.text('No matching recipes'), findsOneWidget);
    });

    testWidgets('filters by folder', (tester) async {
      final builds = BuildCounter.start();
      await pumpLibrary(tester);
      builds.reset();

      await tester.tap(find.text('Breakfast'));
      await tester.pumpAndSettle();

      expect(find.byType(LibraryRecipeCard), findsOneWidget);
      expect(find.text('Oat pancakes'), findsOneWidget);
      expect(builds.of<FolderChips>(), 0);
    });

    testWidgets('shows an empty folder', (tester) async {
      await folders.saveFolder(
        Folder(
          id: const FolderId('empty'),
          name: 'Desserts',
          createdAt: RecipeFixtures.createdAt,
        ),
      );
      await pumpLibrary(tester);

      await tester.tap(find.text('Desserts'));
      await tester.pumpAndSettle();
      expect(find.text('Nothing in this folder yet'), findsOneWidget);
    });

    testWidgets('shows an empty library', (tester) async {
      recipes = FakeRecipeRepository();
      await pumpLibrary(tester);
      expect(find.text('No recipes yet'), findsOneWidget);
    });

    testWidgets('shows an error with a retry button', (tester) async {
      await tester.pumpApp(
        const LibraryScreen(),
        overrides: [folderRepositoryProvider.overrideWithValue(folders)],
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorState), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorState), findsOneWidget);
    });

    testWidgets('creates a folder and selects it', (tester) async {
      await pumpLibrary(tester);

      await tester.tap(find.text('New folder'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Soups');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Soups'), findsOneWidget);
      expect(find.text('Nothing in this folder yet'), findsOneWidget);
    });

    testWidgets('cancelling the folder dialog creates nothing', (tester) async {
      await pumpLibrary(tester);

      await tester.tap(find.text('New folder'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(folders.allFolders, hasLength(1));
    });

    testWidgets('renames, deletes, and restores the selected folder', (
      tester,
    ) async {
      await pumpLibrary(tester);
      expect(find.byTooltip('Folder options'), findsNothing);

      await tester.tap(find.text('Breakfast'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Folder options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename folder'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Mornings');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Mornings'), findsOneWidget);

      await tester.tap(find.byTooltip('Folder options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete folder'));
      await tester.pumpAndSettle();
      expect(find.text('Mornings'), findsNothing);
      expect(find.text('Folder deleted'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('Mornings'), findsOneWidget);
      expect(folders.recipeIdsIn(breakfast), [const RecipeId('oats')]);
    });

    testWidgets('puts a recipe in folders with a long press', (tester) async {
      await pumpLibrary(tester);

      await tester.longPress(find.text('Tomato soup'));
      await tester.pumpAndSettle();
      expect(find.text('Folders'), findsOneWidget);

      await tester.tap(find.widgetWithText(CheckboxListTile, 'Breakfast'));
      await tester.pumpAndSettle();
      expect(folders.recipeIdsIn(breakfast), contains(const RecipeId('soup')));

      await tester.tap(find.widgetWithText(ListTile, 'New folder'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Soups');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      final soups = folders.allFolders.firstWhere((f) => f.name == 'Soups');
      expect(folders.recipeIdsIn(soups.id), [const RecipeId('soup')]);
    });

    testWidgets('the folders sheet says when there are no folders', (
      tester,
    ) async {
      folders = FakeFolderRepository();
      await pumpLibrary(tester);

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
      await pumpLibrary(tester);

      final first = tester.getTopLeft(find.byType(RecipeCard).first);
      final second = tester.getTopLeft(find.byType(RecipeCard).last);
      expect(first.dy, second.dy);
    });
  });
}
