import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/library/application/folders.dart';
import 'package:sousvite/features/library/application/library_filter.dart';
import 'package:sousvite/features/library/application/library_recipes.dart';

import '../../../helpers/fakes/fake_folder_repository.dart';
import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';

void main() {
  const oats = RecipeId('oats');
  const soup = RecipeId('soup');
  const breakfast = FolderId('breakfast');
  late FakeFolderRepository folders;
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
    container = ProviderContainer.test(
      overrides: [
        recipeRepositoryProvider.overrideWithValue(
          FakeRecipeRepository()
            ..seed(recipe: RecipeFixtures.recipe(id: 'oats'))
            ..seed(
              recipe: RecipeFixtures.recipe(
                id: 'soup',
                title: 'Tomato soup',
                createdAt: DateTime.utc(2027),
              ),
            ),
        ),
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
    List<RecipeId>? visible() => container.read(visibleRecipeIdsProvider).value;

    setUp(() => container.listen(visibleRecipeIdsProvider, (_, _) {}));

    test('shows every recipe, newest first', () async {
      expect(await settle(visible), [soup, oats]);
    });

    test('keeps only the chosen folder', () async {
      container.read(libraryFolderProvider.notifier).select(breakfast);
      expect(await settle(visible), [oats]);
    });

    test('keeps only search matches', () async {
      container.read(libraryQueryProvider.notifier).update(' tomato ');
      expect(await settle(visible), [soup]);
    });

    test('combines a folder and a search', () async {
      container.read(libraryFolderProvider.notifier).select(breakfast);
      container.read(libraryQueryProvider.notifier).update('soup');
      expect(await settle(visible), isEmpty);
    });
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
