import 'package:domain/domain.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/editor/editor.dart';
import 'package:sousvite/features/import/import.dart';
import 'package:sousvite/features/library/application/library_scope.dart';
import 'package:sousvite/features/library/library.dart';
import 'package:sousvite/features/library/presentation/folder_grid.dart';
import 'package:sousvite/features/library/presentation/folder_screen.dart';
import 'package:sousvite/features/library/presentation/folder_tile.dart';
import 'package:sousvite/features/library/presentation/library_recipe_card.dart';
import 'package:sousvite/features/library/presentation/library_screen.dart';
import 'package:sousvite/shared/photos/photos.dart';
import 'package:sousvite/shared/photos/stored_photo_image.dart';

import '../../../helpers/fakes/fake_folder_repository.dart';
import '../../../helpers/fakes/fake_photo_store.dart';
import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';
import '../../../helpers/helpers.dart';

void main() {
  const breakfast = FolderId('breakfast');
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

  List<Override> overrides() => [
    recipeRepositoryProvider.overrideWithValue(recipes),
    folderRepositoryProvider.overrideWithValue(folders),
    photoStoreProvider.overrideWithValue(photos),
  ];

  Future<void> pumpLibrary(WidgetTester tester) async {
    await tester.pumpApp(const LibraryScreen(), overrides: overrides());
    await tester.pumpAndSettle();
  }

  Iterable<FolderTile> tiles(WidgetTester tester) =>
      tester.widgetList<FolderTile>(find.byType(FolderTile));

  group(LibraryScreen, () {
    testWidgets('shows only folders: unsorted, each folder, then new', (
      tester,
    ) async {
      await pumpLibrary(tester);

      expect(tiles(tester).map((tile) => tile.title), [
        'Unsorted',
        'Breakfast',
        'New folder',
      ]);
      expect(find.byType(LibraryRecipeCard), findsNothing);
      final breakfastTile = tiles(tester).elementAt(1);
      expect(breakfastTile.countLabel, '1 recipe');
      expect(
        breakfastTile.images.single,
        isA<ResizeImage>().having(
          (image) => image.imageProvider,
          'photo',
          StoredPhotoImage(photos, 'oats-photo'),
        ),
      );
      final unsortedTile = tiles(tester).first;
      expect(unsortedTile.countLabel, '1 recipe');
      expect(unsortedTile.images, isEmpty);
    });

    testWidgets('leaves out the unsorted tile once every recipe is filed', (
      tester,
    ) async {
      await folders.addRecipeToFolder(breakfast, const RecipeId('soup'));
      await pumpLibrary(tester);

      expect(tiles(tester).map((tile) => tile.title), [
        'Breakfast',
        'New folder',
      ]);
      expect(tiles(tester).first.countLabel, '2 recipes');
    });

    testWidgets('renaming a folder rebuilds only its tile', (tester) async {
      final builds = BuildCounter.start();
      await pumpLibrary(tester);
      builds.reset();

      await folders.saveFolder(
        Folder(
          id: breakfast,
          name: 'Mornings',
          createdAt: RecipeFixtures.createdAt,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mornings'), findsOneWidget);
      expect(
        builds.ofKey(const ValueKey<LibraryScope>(FolderRecipes(breakfast))),
        1,
      );
      expect(builds.ofKey(const ValueKey<LibraryScope>(UnsortedRecipes())), 0);
      expect(builds.of<FolderGrid>(), 0);
    });

    testWidgets('searching swaps the tiles for matching recipes', (
      tester,
    ) async {
      await pumpLibrary(tester);

      await tester.enterText(find.byType(SearchBar), 'tomato');
      await tester.pumpAndSettle();
      expect(find.byType(FolderTile), findsNothing);
      expect(find.byType(LibraryRecipeCard), findsOneWidget);
      expect(find.text('Tomato soup'), findsOneWidget);

      await tester.enterText(find.byType(SearchBar), 'waffles');
      await tester.pumpAndSettle();
      expect(find.text('No matching recipes'), findsOneWidget);

      await tester.enterText(find.byType(SearchBar), ' ');
      await tester.pumpAndSettle();
      expect(find.byType(FolderTile), findsNWidgets(3));
    });

    testWidgets('shows three tiles across a phone', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpLibrary(tester);

      final tops = [
        for (final element in find.byType(FolderTile).evaluate())
          tester.getTopLeft(find.byWidget(element.widget)).dy,
      ];
      expect(tops, hasLength(3));
      expect(tops.toSet(), hasLength(1));
    });

    testWidgets('a tile opens its folder, and unsorted opens its own page', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: LibraryRoutes.path,
        routes: LibraryRoutes.routes,
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router, overrides: overrides());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Breakfast'));
      await tester.pumpAndSettle();
      expect(find.byType(FolderScreen), findsOneWidget);
      expect(find.text('Oat pancakes'), findsOneWidget);
      expect(find.text('Tomato soup'), findsNothing);

      router.pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unsorted'));
      await tester.pumpAndSettle();
      expect(find.text('Tomato soup'), findsOneWidget);
      expect(find.text('Oat pancakes'), findsNothing);
    });

    testWidgets('creates a folder from the new folder tile', (tester) async {
      await pumpLibrary(tester);

      await tester.tap(find.text('New folder'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Soups');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Soups'), findsOneWidget);
      expect(folders.allFolders, hasLength(2));
    });

    testWidgets('cancelling the folder dialog creates nothing', (tester) async {
      await pumpLibrary(tester);

      await tester.tap(find.text('New folder'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(folders.allFolders, hasLength(1));
    });

    testWidgets('the add button opens import or a new recipe', (tester) async {
      final router = GoRouter(
        initialLocation: LibraryRoutes.path,
        routes: [
          ...LibraryRoutes.routes,
          GoRoute(
            path: ImportRoutes.path,
            builder: (_, _) => const Text('Import'),
          ),
          GoRoute(
            path: EditorRoutes.path,
            builder: (_, _) => const Text('Editor'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(
        router,
        overrides: [
          recipeRepositoryProvider.overrideWithValue(recipes),
          folderRepositoryProvider.overrideWithValue(folders),
          photoStoreProvider.overrideWithValue(photos),
        ],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AddRecipeButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Write a recipe'));
      await tester.pumpAndSettle();
      expect(find.text('Editor'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AddRecipeButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Import from a link'));
      await tester.pumpAndSettle();
      expect(find.text('Import'), findsOneWidget);
    });
  });
}
