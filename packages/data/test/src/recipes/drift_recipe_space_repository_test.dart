import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:sync/sync.dart';
import 'package:test/test.dart';

import '../../helpers/test_device.dart';

const _shareId = 's_soup';
const _recipeId = RecipeId('r1');

/// One person's device: their own library syncs through their own space,
/// and the joint share through [share].
final class _Device(
  super.id,
  super.space, {
  required final InMemorySyncSpace share,
}) extends TestDevice {
  late final recipes = DriftRecipeRepository(database, recorder: recorder);
  late final spaces = DriftRecipeSpaceRepository(database, recorder: recorder);

  @override
  Map<String, EntityApplier> get appliers => recipes.appliers;

  /// Syncs the joint share, like the app does for each share it's in.
  late final shareEngine = SyncEngine(
    store: DriftLocalStore(database, deviceId: id, appliers: appliers),
    transport: InMemoryTransport(share),
    clock: clock,
    transportKey: 'memory:$_shareId',
    spaceId: _shareId,
  );

  Future<void> syncAll() async {
    await engine.sync();
    await shareEngine.sync();
  }
}

RecipeSnapshot _soup() => RecipeSnapshot(
  recipe: Recipe(
    id: _recipeId,
    title: 'Tomato soup',
    servings: Quantity(4),
    createdAt: DateTime.utc(2026, 11, 17),
    updatedAt: DateTime.utc(2026, 11, 17),
  ),
  ingredientSections: const [
    IngredientSection(
      id: IngredientSectionId('is1'),
      recipeId: _recipeId,
      name: 'Garnish',
      sortKey: SortKey('a'),
    ),
  ],
  ingredientLines: [
    IngredientLine(
      id: const IngredientLineId('l1'),
      recipeId: _recipeId,
      rawText: '1 cup tomatoes',
      sortKey: const SortKey('a'),
      quantity: Quantity(1),
      unit: Unit.cup,
      name: 'tomatoes',
    ),
  ],
  stepSections: const [
    StepSection(
      id: StepSectionId('ss1'),
      recipeId: _recipeId,
      name: 'Prep',
      sortKey: SortKey('a'),
    ),
  ],
  steps: const [
    RecipeStep(
      id: RecipeStepId('t1'),
      recipeId: _recipeId,
      text: 'Simmer.',
      sortKey: SortKey('a'),
    ),
  ],
);

void main() {
  late InMemorySyncSpace share;
  late List<_Device> devices;
  late _Device alice;
  late _Device bob;

  _Device device(String id) {
    final created = _Device(id, InMemorySyncSpace(), share: share);
    devices.add(created);
    return created;
  }

  setUp(() {
    share = InMemorySyncSpace();
    devices = [];
    alice = device('alice');
    bob = device('bob');
  });

  tearDown(() async {
    for (final device in devices) {
      await device.database.close();
    }
  });

  group(DriftRecipeSpaceRepository, () {
    test('keeps a recipe in the own library until it moves', () async {
      await alice.recipes.saveSnapshot(_soup());

      expect(await alice.spaces.sharedSpaceOf(_recipeId), isNull);
      expect(await alice.spaces.watchSharedSpace(_recipeId).first, isNull);
      expect(await alice.spaces.recipesInSharedSpace(_shareId), isEmpty);
    });

    test('moves a recipe into a share', () async {
      await alice.recipes.saveSnapshot(_soup());
      final moves = alice.spaces.watchSharedSpace(_recipeId);
      final seen = expectLater(moves, emitsInOrder([null, _shareId]));
      await Future<void>.delayed(Duration.zero);

      await alice.spaces.moveToSharedSpace(_recipeId, _shareId);

      await seen;
      expect(await alice.spaces.sharedSpaceOf(_recipeId), _shareId);
      expect(await alice.spaces.recipesInSharedSpace(_shareId), [_recipeId]);
    });

    test('gives everyone in the share the whole recipe', () async {
      await alice.recipes.saveSnapshot(_soup());
      await alice.spaces.moveToSharedSpace(_recipeId, _shareId);

      await alice.syncAll();
      await bob.syncAll();

      expect(await bob.recipes.getSnapshot(_recipeId), _soup());
      expect(await bob.spaces.sharedSpaceOf(_recipeId), _shareId);
      expect(await bob.spaces.recipesInSharedSpace(_shareId), [_recipeId]);
    });

    test('sends later edits and deletes to the share both ways', () async {
      await alice.recipes.saveSnapshot(_soup());
      await alice.spaces.moveToSharedSpace(_recipeId, _shareId);
      await alice.syncAll();
      await bob.syncAll();

      final recipe = (await bob.recipes.getRecipe(_recipeId))!;
      await bob.recipes.saveRecipe(recipe.copyWith(title: 'Bob soup'));
      await bob.recipes.deleteIngredientLine(const IngredientLineId('l1'));
      await bob.syncAll();
      await alice.syncAll();

      expect((await alice.recipes.getRecipe(_recipeId))!.title, 'Bob soup');
      expect(
        await alice.recipes.watchIngredientLines(_recipeId).first,
        isEmpty,
      );
    });

    test('leaves the others their recipe when one moves it back', () async {
      await alice.recipes.saveSnapshot(_soup());
      await alice.spaces.moveToSharedSpace(_recipeId, _shareId);
      await alice.syncAll();
      await bob.syncAll();

      await bob.spaces.moveToOwnLibrary(_recipeId);
      final recipe = (await bob.recipes.getRecipe(_recipeId))!;
      await bob.recipes.saveRecipe(recipe.copyWith(title: 'Only Bob'));
      await bob.recipes.deleteRecipe(_recipeId);
      await bob.syncAll();
      await alice.syncAll();

      expect(await bob.spaces.sharedSpaceOf(_recipeId), isNull);
      expect(await bob.spaces.recipesInSharedSpace(_shareId), isEmpty);
      expect(await alice.recipes.getSnapshot(_recipeId), _soup());
      expect(await alice.spaces.sharedSpaceOf(_recipeId), _shareId);
    });

    test('deletes only your own copy of a shared recipe', () async {
      await alice.recipes.saveSnapshot(_soup());
      await alice.spaces.moveToSharedSpace(_recipeId, _shareId);
      await alice.syncAll();
      await bob.syncAll();

      await bob.recipes.deleteRecipe(_recipeId);
      await bob.syncAll();
      await alice.syncAll();

      expect(await bob.recipes.getRecipe(_recipeId), isNull);
      expect(await bob.spaces.sharedSpaceOf(_recipeId), isNull);
      expect(await alice.recipes.getSnapshot(_recipeId), _soup());
      expect(share.changes.where((change) => change.isTombstone), isEmpty);
    });

    test('keeps the moved-back recipe as it was', () async {
      await alice.recipes.saveSnapshot(_soup());
      await alice.spaces.moveToSharedSpace(_recipeId, _shareId);

      await alice.spaces.moveToOwnLibrary(_recipeId);
      await alice.engine.sync();
      // A second device of Alice's, which syncs only her own library.
      final aliceLaptop = _Device('alice-laptop', alice.space, share: share);
      devices.add(aliceLaptop);
      await aliceLaptop.engine.sync();

      expect(await aliceLaptop.recipes.getSnapshot(_recipeId), _soup());
      expect(await aliceLaptop.spaces.sharedSpaceOf(_recipeId), isNull);
    });

    test('records nothing for a missing recipe or a move in place', () async {
      await alice.spaces.moveToSharedSpace(_recipeId, _shareId);
      expect(await alice.changes(), isEmpty);

      await alice.recipes.saveSnapshot(_soup());
      final saved = (await alice.changes()).length;
      await alice.spaces.moveToOwnLibrary(_recipeId);
      expect(await alice.changes(), hasLength(saved));

      await alice.spaces.moveToSharedSpace(_recipeId, _shareId);
      final moved = (await alice.changes()).length;
      await alice.spaces.moveToSharedSpace(_recipeId, _shareId);
      expect(await alice.changes(), hasLength(moved));
    });
  });
}
