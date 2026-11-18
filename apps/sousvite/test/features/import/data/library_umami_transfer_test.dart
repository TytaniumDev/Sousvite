import 'dart:convert';
import 'dart:typed_data';

import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_import/recipe_import.dart';
import 'package:sousvite/features/import/application/import_failure.dart';
import 'package:sousvite/features/import/data/library_umami_transfer.dart';
import 'package:sousvite/features/import/data/umami_files.dart';

import '../../../helpers/fakes/fake_folder_repository.dart';
import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';

/// Hands over [picked] and the [shared] files, and keeps what is saved.
class _FakeFiles() implements UmamiFiles {
  Uint8List? picked;
  final shared = <String, Uint8List>{};
  bool saves = true;
  final saved = <String, Uint8List>{};

  @override
  Future<Uint8List?> pickArchive() async => picked;

  @override
  Future<Uint8List?> takeSharedArchive(String path) async =>
      shared.remove(path);

  @override
  Future<bool> saveArchive(String fileName, Uint8List bytes) async {
    if (saves) saved[fileName] = bytes;
    return saves;
  }
}

UmamiRecipe _umami(String id, String title, String? book, {String? imageUrl}) =>
    (
      snapshot: RecipeSnapshot(
        recipe: RecipeFixtures.recipe(id: id, title: title),
        ingredientLines: [
          RecipeFixtures.line('$id-l', recipeId: id, rawText: '2 cups flour'),
        ],
      ),
      book: book,
      imageUrl: imageUrl,
    );

void main() {
  late _FakeFiles files;
  late FakeRecipeRepository recipes;
  late FakeFolderRepository folders;
  late LibraryUmamiTransfer transfer;
  late List<String?> photoUrls;
  final baking = Folder(
    id: const FolderId('baking'),
    name: 'Baking',
    createdAt: DateTime.utc(2026),
  );

  setUp(() {
    files = _FakeFiles();
    recipes = FakeRecipeRepository();
    folders = FakeFolderRepository();
    photoUrls = [];
    var nextId = 0;
    transfer = LibraryUmamiTransfer(
      files: files,
      recipes: recipes,
      folders: folders,
      newId: () => 'new${nextId++}',
      importPhoto: (url) async {
        photoUrls.add(url);
        return url == null ? null : 'saved:$url';
      },
    );
  });

  group('importLibrary', () {
    test('saves every recipe, filing each in its book', () async {
      folders.seed(baking);
      files.picked = writeUmamiArchive([
        _umami('a', 'Scones', 'Baking'),
        _umami('b', 'Chili', 'Dinner'),
        _umami('c', 'Toast', null),
      ]);

      expect(await transfer.importLibrary(), 3);

      final saved = recipes.writes.whereType<RecipeSnapshot>().toList();
      expect(saved.map((s) => s.recipe.title), ['Scones', 'Chili', 'Toast']);
      // Lines go through the parser on the way in.
      expect(saved.first.ingredientLines.single.unit, Unit.cup);
      expect(folders.allFolders.map((f) => f.name), ['Baking', 'Dinner']);
      expect(folders.recipeIdsIn(baking.id), [saved[0].recipe.id]);
      expect(folders.recipeIdsIn(folders.allFolders.last.id), [
        saved[1].recipe.id,
      ]);
    });

    test('saves each photo, a few at a time, in recipe order', () async {
      files.picked = writeUmamiArchive([
        for (var i = 0; i < LibraryUmamiTransfer.photoDownloads + 2; i++)
          _umami(
            'r$i',
            'Recipe $i',
            null,
            imageUrl: i == 1 ? null : 'https://u.com/$i.jpg',
          ),
      ]);

      await transfer.importLibrary();

      final saved = recipes.writes.whereType<RecipeSnapshot>().toList();
      expect(saved[0].recipe.photoRef, 'saved:https://u.com/0.jpg');
      expect(saved[1].recipe.photoRef, isNull);
      expect(saved.last.recipe.photoRef, 'saved:https://u.com/7.jpg');
      expect(photoUrls, hasLength(LibraryUmamiTransfer.photoDownloads + 2));
    });

    test('does nothing when the user cancels', () async {
      expect(await transfer.importLibrary(), isNull);
      expect(recipes.writes, isEmpty);
    });

    test('fails with invalidFile for a file that is not an export', () async {
      files.picked = Uint8List.fromList(utf8.encode('not a zip'));

      await expectLater(
        transfer.importLibrary(),
        throwsA(
          isA<ImportFailure>().having(
            (f) => f.reason,
            'reason',
            ImportFailureReason.invalidFile,
          ),
        ),
      );
    });
  });

  group('importSharedArchive', () {
    test('saves the recipes in the shared file, then removes it', () async {
      files.shared['/inbox/Umami.zip'] = writeUmamiArchive([
        _umami('a', 'Scones', 'Baking'),
      ]);

      expect(await transfer.importSharedArchive('/inbox/Umami.zip'), 1);

      final saved = recipes.writes.whereType<RecipeSnapshot>().single;
      expect(saved.recipe.title, 'Scones');
      expect(folders.allFolders.single.name, 'Baking');
      expect(files.shared, isEmpty);
    });

    test('fails with invalidFile when the file is gone', () async {
      await expectLater(
        transfer.importSharedArchive('/inbox/missing.zip'),
        throwsA(
          isA<ImportFailure>().having(
            (f) => f.reason,
            'reason',
            ImportFailureReason.invalidFile,
          ),
        ),
      );
      expect(recipes.writes, isEmpty);
    });
  });

  group('exportLibrary', () {
    test('saves every recipe, each in its first folder', () async {
      recipes
        ..seed(
          recipe: RecipeFixtures.recipe(title: 'Scones'),
          lines: [RecipeFixtures.line('l1', rawText: '2 cups flour')],
        )
        ..seed(
          recipe: RecipeFixtures.recipe(id: 'r2', title: 'Toast'),
        );
      folders
        ..seed(baking, [const RecipeId('r1')])
        ..seed(
          Folder(
            id: const FolderId('fav'),
            name: 'Favorites',
            createdAt: DateTime.utc(2026),
          ),
          [const RecipeId('r1')],
        );

      expect(await transfer.exportLibrary(), 2);

      final bytes = files.saved[LibraryUmamiTransfer.exportFileName]!;
      final exported = readUmamiArchive(
        bytes,
        newId: () => 'x',
        now: DateTime.utc(2026),
      );
      expect(
        exported.map((r) => (r.book, r.snapshot.recipe.title)),
        unorderedEquals([('Baking', 'Scones'), (null, 'Toast')]),
      );
      final scones = exported.firstWhere((r) => r.book == 'Baking').snapshot;
      expect(scones.ingredientLines.single.rawText, '2 cups flour');
    });

    test('keeps photo addresses, not photos saved on the device', () async {
      recipes
        ..seed(
          recipe: RecipeFixtures.recipe(title: 'Scones')
              .copyWith(photoRef: 'https://u.com/scones.jpg'),
        )
        ..seed(
          recipe: RecipeFixtures.recipe(
            id: 'r2',
            title: 'Toast',
          ).copyWith(photoRef: 'a-photo-id'),
        );

      await transfer.exportLibrary();

      final exported = readUmamiArchive(
        files.saved[LibraryUmamiTransfer.exportFileName]!,
        newId: () => 'x',
        now: DateTime.utc(2026),
      );
      expect(
        exported.map((r) => (r.snapshot.recipe.title, r.imageUrl)),
        unorderedEquals([
          ('Scones', 'https://u.com/scones.jpg'),
          ('Toast', null),
        ]),
      );
    });

    test('reports a canceled save as null', () async {
      recipes.seed(recipe: RecipeFixtures.recipe());
      files.saves = false;

      expect(await transfer.exportLibrary(), isNull);
    });

    test('exports nothing from an empty library', () async {
      expect(await transfer.exportLibrary(), 0);
      expect(files.saved, isEmpty);
    });
  });
}
