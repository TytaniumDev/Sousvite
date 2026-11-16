import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:drift/drift.dart' show Value;
import 'package:sync/sync.dart';
import 'package:test/test.dart';

import '../../helpers/test_device.dart';

/// A test device with a recipe repository.
final class _Device(super.id, super.space) extends TestDevice {
  late final repository = DriftRecipeRepository(database, recorder: recorder);

  @override
  Map<String, EntityApplier> get appliers => repository.appliers;
}

final _created = DateTime.utc(2026, 11, 16);

Recipe _recipe(String id, String title, {int day = 0}) => Recipe(
  id: RecipeId(id),
  title: title,
  servings: Quantity(4),
  createdAt: _created.add(Duration(days: day)),
  updatedAt: _created.add(Duration(days: day)),
);

IngredientLine _line(
  String id,
  String name, {
  String recipeId = 'r1',
  String sortKey = 'a',
  String? sectionId,
}) => IngredientLine(
  id: IngredientLineId(id),
  recipeId: RecipeId(recipeId),
  rawText: '1 cup $name',
  sortKey: SortKey(sortKey),
  sectionId: sectionId == null ? null : IngredientSectionId(sectionId),
  quantity: Quantity(1),
  unit: Unit.cup,
  name: name,
);

RecipeStep _step(
  String id,
  String text, {
  String sortKey = 'a',
  String? sectionId,
}) => RecipeStep(
  id: RecipeStepId(id),
  recipeId: const RecipeId('r1'),
  text: text,
  sortKey: SortKey(sortKey),
  sectionId: sectionId == null ? null : StepSectionId(sectionId),
);

RecipeSnapshot _soup() => RecipeSnapshot(
  recipe: _recipe('r1', 'Tomato soup'),
  ingredientSections: const [
    IngredientSection(
      id: IngredientSectionId('is1'),
      recipeId: RecipeId('r1'),
      name: 'Garnish',
      sortKey: SortKey('a'),
    ),
  ],
  ingredientLines: [
    _line('l1', 'tomatoes'),
    _line('l2', 'basil', sortKey: 'b', sectionId: 'is1'),
  ],
  stepSections: const [
    StepSection(
      id: StepSectionId('ss1'),
      recipeId: RecipeId('r1'),
      name: 'Prep',
      sortKey: SortKey('a'),
    ),
  ],
  steps: [
    _step('t1', 'Chop the tomatoes.', sectionId: 'ss1'),
    _step('t2', 'Simmer.', sortKey: 'b'),
  ],
);

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

  group(DriftRecipeRepository, () {
    test('saves a snapshot and reads every part back in order', () async {
      final phone = device('phone');
      final repository = phone.repository;
      final soup = _soup();

      await repository.saveSnapshot(soup);

      expect(await repository.getRecipe(const RecipeId('r1')), soup.recipe);
      expect(await repository.getRecipe(const RecipeId('nope')), isNull);
      expect(
        await repository.watchRecipe(const RecipeId('r1')).first,
        soup.recipe,
      );
      expect(
        await repository.watchIngredientSections(const RecipeId('r1')).first,
        soup.ingredientSections,
      );
      expect(
        await repository.watchIngredientLines(const RecipeId('r1')).first,
        soup.ingredientLines,
      );
      expect(
        await repository.watchStepSections(const RecipeId('r1')).first,
        soup.stepSections,
      );
      expect(
        await repository.watchSteps(const RecipeId('r1')).first,
        soup.steps,
      );
    });

    test('lists recipes newest first', () async {
      final repository = device('phone').repository;
      await repository.saveRecipe(_recipe('old', 'Old', day: -1));
      await repository.saveRecipe(_recipe('new', 'New', day: 1));
      await repository.saveRecipe(_recipe('mid', 'Mid'));

      expect(await repository.watchRecipeIds().first, [
        const RecipeId('new'),
        const RecipeId('mid'),
        const RecipeId('old'),
      ]);
    });

    test('saves single parts', () async {
      final repository = device('phone').repository;
      final soup = _soup();
      await repository.saveRecipe(soup.recipe);
      await repository.saveIngredientSection(soup.ingredientSections.single);
      await repository.saveIngredientLine(soup.ingredientLines.first);
      await repository.saveStepSection(soup.stepSections.single);
      await repository.saveStep(soup.steps.first);

      const recipeId = RecipeId('r1');
      expect(
        await repository.watchIngredientSections(recipeId).first,
        hasLength(1),
      );
      expect(
        await repository.watchIngredientLines(recipeId).first,
        hasLength(1),
      );
      expect(await repository.watchStepSections(recipeId).first, hasLength(1));
      expect(await repository.watchSteps(recipeId).first, hasLength(1));
    });

    test('records every field of a new recipe in the change log', () async {
      final phone = device('phone');
      await phone.repository.saveRecipe(_recipe('r1', 'Soup'));

      final changes = await phone.changes();

      expect(changes.map((change) => change.entity).toSet(), {'recipe'});
      expect(
        changes.map((change) => change.field),
        containsAll(['title', 'servings', 'createdAt', 'updatedAt', 'notes']),
      );
      expect(changes.every((change) => change.spaceId == 'private'), isTrue);
    });

    test('records only the fields an edit changed', () async {
      final phone = device('phone');
      final recipe = _recipe('r1', 'Soup');
      await phone.repository.saveRecipe(recipe);
      final before = (await phone.changes()).length;

      await phone.repository.saveRecipe(recipe.copyWith(title: 'Stew'));
      await phone.repository.saveRecipe(recipe.copyWith(title: 'Stew'));

      final added = (await phone.changes()).skip(before);
      expect(added.map((change) => (change.field, change.value)), [
        ('title', 'Stew'),
      ]);
    });

    test('emits a watched value again only when it changes', () async {
      final phone = device('phone');
      final repository = phone.repository;
      await repository.saveSnapshot(_soup());
      final titles = <String?>[];
      final lines = <int>[];
      final titleSub = repository
          .watchRecipe(const RecipeId('r1'))
          .listen((recipe) => titles.add(recipe?.title));
      final lineSub = repository
          .watchIngredientLines(const RecipeId('r1'))
          .listen((value) => lines.add(value.length));
      await pumpEventQueue();

      // A step edit touches neither the recipe row nor its lines.
      await repository.saveStep(_step('t2', 'Simmer gently.', sortKey: 'b'));
      await pumpEventQueue();
      await repository.saveRecipe(_recipe('r1', 'Soup'));
      await pumpEventQueue();

      expect(titles, ['Tomato soup', 'Soup']);
      expect(lines, [2]);
      await titleSub.cancel();
      await lineSub.cancel();
    });

    group('search', () {
      late DriftRecipeRepository repository;

      setUp(() async {
        repository = device('phone').repository;
        await repository.saveSnapshot(_soup());
        await repository.saveSnapshot(
          RecipeSnapshot(
            recipe: _recipe('r2', 'Chicken tikka masala', day: 1),
            ingredientLines: [_line('l9', 'crème fraîche', recipeId: 'r2')],
          ),
        );
      });

      Future<List<RecipeId>> search(String query) =>
          repository.watchSearch(query).first;

      test('finds recipes by the start of words in the title', () async {
        expect(await search('chick tik'), [const RecipeId('r2')]);
        expect(await search('soup'), [const RecipeId('r1')]);
        expect(await search('chicken soup'), isEmpty);
      });

      test('finds recipes by ingredient name, ignoring accents', () async {
        expect(await search('basil'), [const RecipeId('r1')]);
        expect(await search('creme'), [const RecipeId('r2')]);
      });

      test('finds recipes by folder name', () async {
        final database = devices.single.database;
        await database
            .into(database.folders)
            .insert(
              FoldersCompanion.insert(
                id: 'f1',
                name: 'Weeknight',
                createdAt: _created,
              ),
            );
        await database
            .into(database.folderEntries)
            .insert(
              FolderEntriesCompanion.insert(
                folderId: 'f1',
                recipeId: 'r1',
                addedAt: _created,
              ),
            );

        expect(await search('weeknight'), [const RecipeId('r1')]);

        await (database.update(database.folders)
              ..where((row) => row.id.equals('f1')))
            .write(const FoldersCompanion(name: Value('Sunday')));
        expect(await search('weeknight'), isEmpty);
        expect(await search('sunday'), [const RecipeId('r1')]);

        await database.delete(database.folderEntries).go();
        expect(await search('sunday'), isEmpty);
      });

      test('updates results as recipes change', () async {
        await repository.saveRecipe(_recipe('r1', 'Gazpacho'));
        await repository.deleteIngredientLine(const IngredientLineId('l2'));

        expect(await search('gazpacho'), [const RecipeId('r1')]);
        expect(await search('basil'), isEmpty);

        await repository.deleteRecipe(const RecipeId('r2'));
        expect(await search('chicken'), isEmpty);
      });

      test('lists every recipe for an empty query', () async {
        expect(await search('  '), [
          const RecipeId('r2'),
          const RecipeId('r1'),
        ]);
      });
    });

    group('deletes', () {
      late _Device phone;
      const recipeId = RecipeId('r1');

      setUp(() async {
        phone = device('phone');
        await phone.repository.saveSnapshot(_soup());
      });

      Future<Set<String>> tombstones() => phone.tombstones();

      test('a recipe with every part, leaving tombstones', () async {
        await phone.repository.deleteRecipe(recipeId);

        expect(await phone.repository.getRecipe(recipeId), isNull);
        expect(
          await phone.repository.watchIngredientLines(recipeId).first,
          isEmpty,
        );
        expect(
          await phone.repository.watchIngredientSections(recipeId).first,
          isEmpty,
        );
        expect(await phone.repository.watchSteps(recipeId).first, isEmpty);
        expect(
          await phone.repository.watchStepSections(recipeId).first,
          isEmpty,
        );
        expect(await tombstones(), {
          'r1',
          'l1',
          'l2',
          'is1',
          't1',
          't2',
          'ss1',
        });
      });

      test('an ingredient section with its lines', () async {
        await phone.repository.deleteIngredientSection(
          const IngredientSectionId('is1'),
        );

        expect(await phone.repository.watchIngredientLines(recipeId).first, [
          _soup().ingredientLines.first,
        ]);
        expect(await tombstones(), {'is1', 'l2'});
      });

      test('a step section with its steps', () async {
        await phone.repository.deleteStepSection(const StepSectionId('ss1'));

        expect(await phone.repository.watchSteps(recipeId).first, [
          _soup().steps.last,
        ]);
        expect(await tombstones(), {'ss1', 't1'});
      });

      test('single lines and steps', () async {
        await phone.repository.deleteIngredientLine(
          const IngredientLineId('l1'),
        );
        await phone.repository.deleteStep(const RecipeStepId('t2'));

        expect(await tombstones(), {'l1', 't2'});
      });

      test('nothing for a section that is already gone', () async {
        await phone.repository.deleteIngredientSection(
          const IngredientSectionId('gone'),
        );
        await phone.repository.deleteStepSection(const StepSectionId('gone'));

        expect(await tombstones(), isEmpty);
      });
    });

    group('sync', () {
      test('copies a recipe with every part to another device', () async {
        final phone = device('phone');
        final laptop = device('laptop');
        await phone.repository.saveSnapshot(_soup());

        await phone.engine.sync();
        await laptop.engine.sync();

        const recipeId = RecipeId('r1');
        final soup = _soup();
        expect(await laptop.repository.getRecipe(recipeId), soup.recipe);
        expect(
          await laptop.repository.watchIngredientLines(recipeId).first,
          soup.ingredientLines,
        );
        expect(
          await laptop.repository.watchIngredientSections(recipeId).first,
          soup.ingredientSections,
        );
        expect(await laptop.repository.watchSteps(recipeId).first, soup.steps);
        expect(
          await laptop.repository.watchStepSections(recipeId).first,
          soup.stepSections,
        );
        expect(await laptop.repository.watchSearch('basil').first, [recipeId]);
      });

      test('keeps edits to different fields from two devices', () async {
        final phone = device('phone');
        final laptop = device('laptop');
        final recipe = _recipe('r1', 'Soup');
        await phone.repository.saveRecipe(recipe);
        await phone.engine.sync();
        await laptop.engine.sync();

        await phone.repository.saveRecipe(recipe.copyWith(title: 'Stew'));
        await laptop.repository.saveRecipe(recipe.copyWith(notes: 'Salty'));
        await phone.engine.sync();
        await laptop.engine.sync();
        await phone.engine.sync();

        final merged = recipe.copyWith(title: 'Stew', notes: 'Salty');
        expect(await phone.repository.getRecipe(recipe.id), merged);
        expect(await laptop.repository.getRecipe(recipe.id), merged);
      });

      test('brings back a recipe saved again after a delete', () async {
        final phone = device('phone');
        final laptop = device('laptop');
        final recipe = _recipe('r1', 'Soup');
        await phone.repository.saveRecipe(recipe);
        await phone.repository.deleteRecipe(recipe.id);
        await phone.repository.saveRecipe(recipe);

        await phone.engine.sync();
        await laptop.engine.sync();

        expect(await laptop.repository.getRecipe(recipe.id), recipe);
      });

      test('removes what another device deleted', () async {
        final phone = device('phone');
        final laptop = device('laptop');
        await phone.repository.saveSnapshot(_soup());
        await phone.engine.sync();
        await laptop.engine.sync();

        await phone.repository.deleteRecipe(const RecipeId('r1'));
        await phone.engine.sync();
        await laptop.engine.sync();

        expect(await laptop.repository.getRecipe(const RecipeId('r1')), isNull);
        expect(
          await laptop.repository.watchSteps(const RecipeId('r1')).first,
          isEmpty,
        );
      });
    });
  });
}
