import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/library/application/folders.dart';
import 'package:sousvite/features/library/application/library_filter.dart';
import 'package:sousvite/features/library/application/library_recipes.dart';
import 'package:sousvite/features/library/application/library_scope.dart';

import '../../../helpers/fakes/fake_folder_repository.dart';
import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';

void main() {
  const oats = RecipeId('oats');
  const soup = RecipeId('soup');
  const breakfast = FolderId('breakfast');
  late FakeFolderRepository folders;
  late FakeRecipeRepository recipes;
  late ProviderContainer container;

  setUp(() {
    folders = FakeFolderRepository()
      ..seed(
        Folder(
          id: breakfast,
          name: 'Breakfast',
          createdAt: RecipeFixtures.createdAt,
        ),
        [oats],
      );
    recipes = FakeRecipeRepository()
      ..seed(recipe: RecipeFixtures.recipe(id: 'oats'))
      ..seed(
        recipe: RecipeFixtures.recipe(
          id: 'soup',
          title: 'Tomato soup',
          createdAt: DateTime.utc(2027),
        ),
      );
    container = ProviderContainer.test(
      overrides: [
        recipeRepositoryProvider.overrideWithValue(recipes),
        folderRepositoryProvider.overrideWithValue(folders),
      ],
    );
  });

  Future<T> settle<T>(T Function() read) async {
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    return read();
  }

  group('visibleRecipeIds', () {
    List<RecipeId>? visible(LibraryScope scope) =>
        container.read(visibleRecipeIdsProvider(scope)).value;

    void listen(LibraryScope scope) =>
        container.listen(visibleRecipeIdsProvider(scope), (_, _) {});

    test('shows every recipe, newest first', () async {
      listen(const AllRecipes());
      expect(await settle(() => visible(const AllRecipes())), [soup, oats]);
    });

    test('keeps only one folder', () async {
      listen(const FolderRecipes(breakfast));
      expect(await settle(() => visible(const FolderRecipes(breakfast))), [
        oats,
      ]);
    });

    test('keeps only recipes in no folder', () async {
      listen(const UnsortedRecipes());
      expect(await settle(() => visible(const UnsortedRecipes())), [soup]);
    });

    test('keeps only search matches', () async {
      listen(const AllRecipes());
      container
          .read(libraryQueryProvider(const AllRecipes()).notifier)
          .update(' tomato ');
      expect(await settle(() => visible(const AllRecipes())), [soup]);
      expect(container.read(isSearchingProvider(const AllRecipes())), isTrue);
    });

    test('combines a folder and its own search', () async {
      listen(const FolderRecipes(breakfast));
      container
          .read(libraryQueryProvider(const FolderRecipes(breakfast)).notifier)
          .update('soup');
      expect(
        await settle(() => visible(const FolderRecipes(breakfast))),
        isEmpty,
      );
      expect(container.read(isSearchingProvider(const AllRecipes())), isFalse);
    });
  });

  group('scopeRecipeCount', () {
    test('counts the recipes in a scope', () async {
      for (final scope in [
        const AllRecipes(),
        const UnsortedRecipes(),
        const FolderRecipes(breakfast),
      ]) {
        container.listen(scopeRecipeCountProvider(scope), (_, _) {});
      }
      expect(
        await settle(
          () => container.read(scopeRecipeCountProvider(const AllRecipes())),
        ),
        2,
      );
      expect(
        container.read(scopeRecipeCountProvider(const UnsortedRecipes())),
        1,
      );
      expect(
        container.read(
          scopeRecipeCountProvider(const FolderRecipes(breakfast)),
        ),
        1,
      );
    });
  });

  group('coverPhotos', () {
    const scope = AllRecipes();

    test('takes the newest photos, at most four', () async {
      for (var i = 0; i < 6; i++) {
        recipes.seed(
          recipe: RecipeFixtures.recipe(
            id: 'photo$i',
            createdAt: DateTime.utc(2028, 1, i + 1),
          ).copyWith(photoRef: 'p$i'),
        );
      }
      container.listen(coverPhotosProvider(scope), (_, _) {});
      expect(await settle(() => container.read(coverPhotosProvider(scope))), [
        'p5',
        'p4',
        'p3',
        'p2',
      ]);
    });

    test('notifies only when the photos change', () async {
      var notifications = 0;
      container.listen(coverPhotosProvider(scope), (_, _) => notifications++);
      await settle(() => null);
      expect(container.read(coverPhotosProvider(scope)), isEmpty);
      notifications = 0;

      await recipes.saveRecipe(
        RecipeFixtures.recipe(id: 'oats', title: 'Oat waffles'),
      );
      await settle(() => null);
      expect(notifications, 0);

      await recipes.saveRecipe(
        RecipeFixtures.recipe(id: 'oats').copyWith(photoRef: 'oats-photo'),
      );
      expect(await settle(() => container.read(coverPhotosProvider(scope))), [
        'oats-photo',
      ]);
      expect(notifications, 1);
    });
  });

  test('scopes are equal by what they list', () {
    expect(const FolderRecipes(breakfast), const FolderRecipes(breakfast));
    expect(
      const FolderRecipes(breakfast).hashCode,
      const FolderRecipes(breakfast).hashCode,
    );
    expect(
      const FolderRecipes(breakfast),
      isNot(const FolderRecipes(FolderId('dinner'))),
    );
    expect(const AllRecipes(), isNot(const UnsortedRecipes()));
    expect(
      const AllRecipes().hashCode,
      isNot(const UnsortedRecipes().hashCode),
    );
  });

  group(FolderEditor, () {
    FolderEditor editor() => container.read(folderEditorProvider.notifier);

    test('creates and renames a folder', () async {
      final id = await editor().create('  Dinner ');
      expect((await folders.getFolder(id))?.name, 'Dinner');

      await editor().rename(id, 'Weeknight dinner');
      expect((await folders.getFolder(id))?.name, 'Weeknight dinner');

      await editor().rename(const FolderId('gone'), 'Nothing');
      expect(await folders.getFolder(const FolderId('gone')), isNull);
    });

    test('deletes a folder and undoes it with its recipes', () async {
      final deleted = await editor().delete(breakfast);
      expect(await folders.getFolder(breakfast), isNull);
      expect(await editor().delete(breakfast), isNull);

      await editor().restore(deleted!);
      expect(await folders.watchRecipeIdsInFolder(breakfast).first, [oats]);
    });

    test('puts a recipe in several folders', () async {
      final dinner = await editor().create('Dinner');
      await editor().setRecipeInFolder(dinner, oats, inFolder: true);
      container
        ..listen(isRecipeInFolderProvider(dinner, oats), (_, _) {})
        ..listen(isRecipeInFolderProvider(breakfast, oats), (_, _) {});
      expect(
        await settle(
          () => container.read(isRecipeInFolderProvider(dinner, oats)),
        ),
        isTrue,
      );
      expect(container.read(isRecipeInFolderProvider(breakfast, oats)), isTrue);

      await editor().setRecipeInFolder(dinner, oats, inFolder: false);
      expect(await folders.watchRecipeIdsInFolder(dinner).first, isEmpty);
    });
  });

  test('folder ids ignore renames', () async {
    var notifications = 0;
    container.listen(folderIdsProvider, (_, _) => notifications++);
    await settle(() => null);
    notifications = 0;

    await container
        .read(folderEditorProvider.notifier)
        .rename(breakfast, 'Mornings');
    await settle(() => null);
    expect(notifications, 0);
    expect(container.read(folderNameProvider(breakfast)), 'Mornings');
  });
}
