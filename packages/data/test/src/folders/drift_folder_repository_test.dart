import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:sync/sync.dart';
import 'package:test/test.dart';

import '../../helpers/test_device.dart';

/// A test device with folder and recipe repositories.
final class _Device(super.id, super.space) extends TestDevice {
  late final folders = DriftFolderRepository(
    database,
    recorder: recorder,
    now: () => DateTime.utc(2026, 11, 16).add(Duration(minutes: time++)),
  );
  late final recipes = DriftRecipeRepository(database, recorder: recorder);

  @override
  Map<String, EntityApplier> get appliers => {
    ...folders.appliers,
    ...recipes.appliers,
  };

  Future<void> addRecipe(String id) => recipes.saveRecipe(
    Recipe(
      id: RecipeId(id),
      title: 'Recipe $id',
      servings: Quantity(2),
      createdAt: DateTime.utc(2026, 11, 16),
      updatedAt: DateTime.utc(2026, 11, 16),
    ),
  );
}

Folder _folder(String id, String name) =>
    Folder(id: FolderId(id), name: name, createdAt: DateTime.utc(2026, 11, 16));

void main() {
  late InMemorySyncSpace space;
  late List<_Device> devices;

  _Device device(String id) {
    final created = _Device(id, space);
    devices.add(created);
    return created;
  }

  setUp(() {
    space = InMemorySyncSpace();
    devices = [];
  });

  tearDown(() async {
    for (final device in devices) {
      await device.database.close();
    }
  });

  const weeknight = FolderId('f1');

  group(DriftFolderRepository, () {
    test('lists folders by name, ignoring case', () async {
      final folders = device('phone').folders;
      await folders.saveFolder(_folder('f1', 'weeknight'));
      await folders.saveFolder(_folder('f2', 'Baking'));
      await folders.saveFolder(_folder('f3', 'Soups'));

      expect(
        (await folders.watchFolders().first).map((folder) => folder.name),
        ['Baking', 'Soups', 'weeknight'],
      );
      expect(await folders.getFolder(weeknight), _folder('f1', 'weeknight'));
      expect(await folders.getFolder(const FolderId('nope')), isNull);
    });

    test('renames a folder, recording only the name', () async {
      final phone = device('phone');
      await phone.folders.saveFolder(_folder('f1', 'Weeknight'));
      final before = (await phone.changes()).length;

      await phone.folders.saveFolder(_folder('f1', 'Quick'));

      final added = (await phone.changes()).skip(before);
      expect(added.map((change) => (change.field, change.value)), [
        ('name', 'Quick'),
      ]);
    });

    test(
      'lists the recipes in a folder in the order they were added',
      () async {
        final phone = device('phone');
        await phone.folders.saveFolder(_folder('f1', 'Weeknight'));
        for (final id in ['r1', 'r2', 'r3']) {
          await phone.addRecipe(id);
        }

        await phone.folders.addRecipeToFolder(weeknight, const RecipeId('r2'));
        await phone.folders.addRecipeToFolder(weeknight, const RecipeId('r1'));
        await phone.folders.addRecipeToFolder(weeknight, const RecipeId('r2'));

        expect(await phone.folders.watchRecipeIdsInFolder(weeknight).first, [
          const RecipeId('r2'),
          const RecipeId('r1'),
        ]);
      },
    );

    test('leaves out recipes that were deleted', () async {
      final phone = device('phone');
      await phone.addRecipe('r1');
      await phone.folders.addRecipeToFolder(weeknight, const RecipeId('r1'));

      await phone.recipes.deleteRecipe(const RecipeId('r1'));

      expect(
        await phone.folders.watchRecipeIdsInFolder(weeknight).first,
        isEmpty,
      );
    });

    test('lists recipes in any folder that still exists', () async {
      final phone = device('phone');
      const soups = FolderId('f2');
      await phone.folders.saveFolder(_folder('f1', 'Weeknight'));
      await phone.folders.saveFolder(_folder('f2', 'Soups'));
      for (final id in ['r1', 'r2', 'r3']) {
        await phone.addRecipe(id);
      }
      await phone.folders.addRecipeToFolder(weeknight, const RecipeId('r1'));
      await phone.folders.addRecipeToFolder(soups, const RecipeId('r1'));
      await phone.folders.addRecipeToFolder(soups, const RecipeId('r2'));
      // An entry whose folder row never arrived, as sync can leave one.
      await phone.folders.addRecipeToFolder(
        const FolderId('gone'),
        const RecipeId('r3'),
      );
      // An entry whose recipe is gone.
      await phone.folders.addRecipeToFolder(weeknight, const RecipeId('r4'));

      expect(await phone.folders.watchRecipeIdsInAnyFolder().first, {
        const RecipeId('r1'),
        const RecipeId('r2'),
      });

      expect(await phone.folders.watchFolderIdsOf(const RecipeId('r1')).first, {
        weeknight,
        soups,
      });
      expect(
        await phone.folders.watchFolderIdsOf(const RecipeId('r3')).first,
        isEmpty,
      );

      await phone.folders.deleteFolder(soups);
      expect(await phone.folders.watchRecipeIdsInAnyFolder().first, {
        const RecipeId('r1'),
      });
      expect(await phone.folders.watchFolderIdsOf(const RecipeId('r1')).first, {
        weeknight,
      });
    });

    test('removes a recipe from a folder', () async {
      final phone = device('phone');
      await phone.addRecipe('r1');
      await phone.folders.addRecipeToFolder(weeknight, const RecipeId('r1'));

      await phone.folders.removeRecipeFromFolder(
        weeknight,
        const RecipeId('r1'),
      );
      await phone.folders.removeRecipeFromFolder(
        weeknight,
        const RecipeId('r1'),
      );

      expect(
        await phone.folders.watchRecipeIdsInFolder(weeknight).first,
        isEmpty,
      );
      expect(await phone.tombstones(), {'f1/r1'});
    });

    test('deletes a folder with its entries, keeping the recipes', () async {
      final phone = device('phone');
      await phone.folders.saveFolder(_folder('f1', 'Weeknight'));
      await phone.addRecipe('r1');
      await phone.folders.addRecipeToFolder(weeknight, const RecipeId('r1'));

      await phone.folders.deleteFolder(weeknight);

      expect(await phone.folders.watchFolders().first, isEmpty);
      expect(await phone.recipes.getRecipe(const RecipeId('r1')), isNotNull);
      expect(await phone.tombstones(), {'f1', 'f1/r1'});
    });

    test('emits folders again only when they change', () async {
      final phone = device('phone');
      await phone.folders.saveFolder(_folder('f1', 'Weeknight'));
      final names = <List<String>>[];
      final subscription = phone.folders.watchFolders().listen(
        (folders) => names.add([for (final folder in folders) folder.name]),
      );
      await pumpEventQueue();

      await phone.addRecipe('r1');
      await phone.folders.addRecipeToFolder(weeknight, const RecipeId('r1'));
      await pumpEventQueue();
      await phone.folders.saveFolder(_folder('f1', 'Quick'));
      await pumpEventQueue();

      expect(names, [
        ['Weeknight'],
        ['Quick'],
      ]);
      await subscription.cancel();
    });

    test('syncs folders, entries, and deletes to another device', () async {
      final phone = device('phone');
      final laptop = device('laptop');
      await phone.folders.saveFolder(_folder('f1', 'Weeknight'));
      await phone.addRecipe('r1');
      await phone.folders.addRecipeToFolder(weeknight, const RecipeId('r1'));
      await phone.engine.sync();
      await laptop.engine.sync();

      expect(await laptop.folders.watchFolders().first, [
        _folder('f1', 'Weeknight'),
      ]);
      expect(await laptop.folders.watchRecipeIdsInFolder(weeknight).first, [
        const RecipeId('r1'),
      ]);
      expect(await laptop.recipes.watchSearch('weeknight').first, [
        const RecipeId('r1'),
      ]);

      await phone.folders.removeRecipeFromFolder(
        weeknight,
        const RecipeId('r1'),
      );
      await phone.engine.sync();
      await laptop.engine.sync();

      expect(
        await laptop.folders.watchRecipeIdsInFolder(weeknight).first,
        isEmpty,
      );
    });

    test('restores a deleted folder on every device', () async {
      final phone = device('phone');
      final laptop = device('laptop');
      final folder = _folder('f1', 'Weeknight');
      await phone.folders.saveFolder(folder);
      await phone.folders.deleteFolder(weeknight);
      await phone.folders.saveFolder(folder);
      await phone.engine.sync();
      await laptop.engine.sync();

      expect(await laptop.folders.getFolder(weeknight), folder);
    });
  });

  group(FolderEntryCodec, () {
    test('waits for every required field', () {
      expect(FolderEntryCodec().decode('f1/r1', {'folderId': 'f1'}), isNull);
      expect(FolderCodec().decode('f1', {'name': 'Soups'}), isNull);
    });
  });
}
