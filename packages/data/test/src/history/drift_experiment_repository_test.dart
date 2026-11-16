import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:sync/sync.dart';
import 'package:test/test.dart';

import '../../helpers/test_device.dart';

/// A test device with recipe and experiment repositories.
final class _Device(super.id, super.space) extends TestDevice {
  late final recipes = DriftRecipeRepository(database, recorder: recorder);
  late final history = DriftExperimentRepository(
    database,
    recorder: recorder,
    recipes: recipes,
    now: () => DateTime.utc(2026, 11, 16).add(Duration(minutes: time++)),
  );

  @override
  Map<String, EntityApplier> get appliers => {
    ...recipes.appliers,
    ...history.appliers,
  };
}

const _soupId = RecipeId('soup');

RecipeSnapshot _soup() => RecipeSnapshot(
  recipe: Recipe(
    id: _soupId,
    title: 'Soup',
    servings: Quantity(4),
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    notes: 'Mine',
  ),
  ingredientSections: const [
    IngredientSection(
      id: IngredientSectionId('is1'),
      recipeId: _soupId,
      name: 'Garnish',
      sortKey: SortKey('a'),
    ),
  ],
  ingredientLines: const [
    IngredientLine(
      id: IngredientLineId('l1'),
      recipeId: _soupId,
      rawText: 'butter',
      sortKey: SortKey('a'),
      name: 'butter',
    ),
    IngredientLine(
      id: IngredientLineId('l2'),
      recipeId: _soupId,
      rawText: 'basil',
      sortKey: SortKey('b'),
      sectionId: IngredientSectionId('is1'),
    ),
  ],
  stepSections: const [
    StepSection(
      id: StepSectionId('ss1'),
      recipeId: _soupId,
      name: 'Prep',
      sortKey: SortKey('a'),
    ),
  ],
  steps: const [
    RecipeStep(
      id: RecipeStepId('t1'),
      recipeId: _soupId,
      text: 'Melt the butter.',
      sortKey: SortKey('a'),
      sectionId: StepSectionId('ss1'),
    ),
  ],
);

/// The parts of [snapshot] without ids, to compare copies.
List<Object> _shape(RecipeSnapshot snapshot) => [
  snapshot.recipe.title,
  snapshot.recipe.notes,
  [for (final line in snapshot.ingredientLines) line.rawText],
  [for (final section in snapshot.ingredientSections) section.name],
  [for (final step in snapshot.steps) step.text],
  [for (final section in snapshot.stepSections) section.name],
];

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

  group(DriftExperimentRepository, () {
    late _Device phone;

    setUp(() async {
      phone = device('phone');
      await phone.recipes.saveSnapshot(_soup());
    });

    test('starts an experiment on a hidden copy of the recipe', () async {
      final experiment = await phone.history.startExperiment(_soupId);

      expect(experiment.recipeId, _soupId);
      expect(experiment.outcome, ExperimentOutcome.open);
      expect(await phone.history.getExperiment(experiment.id), experiment);
      expect(await phone.history.watchExperiments(_soupId).first, [experiment]);

      final working = await phone.recipes.getSnapshot(
        experiment.workingRecipeId,
      );
      expect(_shape(working!), _shape(_soup()));
      expect(working.ingredientLines.last.sectionId, isNotNull);
      expect(await phone.recipes.watchRecipeIds().first, [_soupId]);
      expect(await phone.recipes.watchSearch('soup').first, [_soupId]);

      final base = await phone.history.getVersionSnapshot(
        experiment.baseVersionId,
      );
      expect(base, _soup());
      expect(await phone.history.watchVersions(_soupId).first, hasLength(1));
    });

    test(
      'promotes an experiment, keeping the old recipe as a version',
      () async {
        final experiment = await phone.history.startExperiment(_soupId);
        final working = (await phone.recipes.getSnapshot(
          experiment.workingRecipeId,
        ))!;
        await phone.recipes.saveIngredientLine(
          working.ingredientLines.first.copyWith(rawText: 'olive oil'),
        );
        await phone.recipes.deleteStep(working.steps.single.id);

        await phone.history.promoteExperiment(experiment.id);

        final promoted = (await phone.recipes.getSnapshot(_soupId))!;
        expect(promoted.ingredientLines.map((line) => line.rawText), [
          'olive oil',
          'basil',
        ]);
        expect(promoted.steps, isEmpty);
        expect(promoted.recipe.createdAt, DateTime.utc(2026));
        expect(
          (await phone.history.getExperiment(experiment.id))!.outcome,
          ExperimentOutcome.adopted,
        );
        final versions = await phone.history.watchVersions(_soupId).first;
        expect(versions, hasLength(2));
        expect(
          await phone.history.getVersionSnapshot(versions.first.id),
          _soup(),
        );
      },
    );

    test('restores a version, saving the current recipe first', () async {
      final experiment = await phone.history.startExperiment(_soupId);
      await phone.recipes.saveRecipe(_soup().recipe.copyWith(title: 'Stew'));
      await phone.recipes.deleteIngredientLine(const IngredientLineId('l1'));
      await phone.recipes.saveStep(
        _soup().steps.single.copyWith(
          id: const RecipeStepId('t2'),
          text: 'Add stock.',
          sortKey: const SortKey('b'),
        ),
      );

      await phone.history.restoreVersion(experiment.baseVersionId);

      final restored = (await phone.recipes.getSnapshot(_soupId))!;
      expect(_shape(restored), _shape(_soup()));
      expect(restored.ingredientLines, _soup().ingredientLines);
      final versions = await phone.history.watchVersions(_soupId).first;
      expect(versions, hasLength(2));
      final saved = await phone.history.getVersionSnapshot(versions.first.id);
      expect(saved!.recipe.title, 'Stew');
    });

    test('restores a recipe that was deleted', () async {
      final experiment = await phone.history.startExperiment(_soupId);
      await phone.recipes.deleteRecipe(_soupId);

      await phone.history.restoreVersion(experiment.baseVersionId);

      expect(
        _shape((await phone.recipes.getSnapshot(_soupId))!),
        _shape(_soup()),
      );
    });

    test('does nothing for a missing version or experiment', () async {
      await phone.history.restoreVersion(const RecipeVersionId('nope'));
      await phone.history.promoteExperiment(const ExperimentId('nope'));
      await phone.history.deleteExperiment(const ExperimentId('nope'));

      expect(
        await phone.history.getVersion(const RecipeVersionId('nope')),
        isNull,
      );
      expect(
        await phone.history.getVersionSnapshot(const RecipeVersionId('nope')),
        isNull,
      );
      expect(await phone.history.watchVersions(_soupId).first, isEmpty);
    });

    test('cannot start an experiment on a missing recipe', () async {
      await expectLater(
        phone.history.startExperiment(const RecipeId('nope')),
        throwsStateError,
      );
      expect(
        await phone.history.watchVersions(const RecipeId('nope')).first,
        isEmpty,
      );
    });

    test('saves notes and deletes an experiment with its copy', () async {
      final experiment = await phone.history.startExperiment(_soupId);
      final noted = experiment.copyWith(
        changeDescription: 'Olive oil',
        notes: 'Lighter',
        outcome: ExperimentOutcome.kept,
      );
      await phone.history.saveExperiment(noted);
      expect(await phone.history.getExperiment(experiment.id), noted);

      await phone.history.deleteExperiment(experiment.id);

      expect(await phone.history.watchExperiments(_soupId).first, isEmpty);
      expect(await phone.recipes.getRecipe(experiment.workingRecipeId), isNull);
    });

    test('saves a version as given', () async {
      final version = RecipeVersion(
        id: const RecipeVersionId('v1'),
        recipeId: _soupId,
        createdAt: DateTime.utc(2026, 11),
        snapshotJson: RecipeSnapshotJson.encode(_soup()),
        summary: 'Before the move',
      );

      await phone.history.saveVersion(version);

      expect(await phone.history.getVersion(version.id), version);
    });

    group('preserveLosingEdits', () {
      Change losing(String entity, String id, String field, Object? value) =>
          Change(
            id: 'lost-$id',
            entity: entity,
            entityId: id,
            field: field,
            value: value,
            hlc: const Hlc(1, 0, 'laptop'),
            deviceId: 'laptop',
            spaceId: 'private',
          );

      test('keeps losing notes and step text as versions', () async {
        await phone.history.preserveLosingEdits([
          losing('recipe', 'soup', 'notes', 'Theirs'),
          losing('recipe_step', 't1', 'text', 'Brown the butter.'),
        ]);

        final notes = await phone.history.getVersionSnapshot(
          const RecipeVersionId('preserved-lost-soup'),
        );
        final step = await phone.history.getVersionSnapshot(
          const RecipeVersionId('preserved-lost-t1'),
        );
        expect(notes!.recipe.notes, 'Theirs');
        expect(step!.steps.single.text, 'Brown the butter.');
        expect((await phone.recipes.getRecipe(_soupId))!.notes, 'Mine');
      });

      test('skips edits it cannot place', () async {
        await phone.history.preserveLosingEdits([
          losing('recipe', 'gone', 'notes', 'x'),
          losing('recipe_step', 'gone', 'text', 'x'),
          losing('recipe', 'soup', 'title', 42),
          losing('grocery_item', 'g1', 'name', 'x'),
        ]);

        expect(await phone.history.watchVersions(_soupId).first, isEmpty);
      });

      test('skips a step whose recipe is gone', () async {
        await phone.database.recipeDao.deleteRecipe('soup');

        await phone.history.preserveLosingEdits([
          losing('recipe_step', 't1', 'text', 'x'),
        ]);

        expect(await phone.history.watchVersions(_soupId).first, isEmpty);
      });
    });

    test('syncs experiments and versions to another device', () async {
      final laptop = device('laptop');
      final experiment = await phone.history.startExperiment(_soupId);
      await phone.engine.sync();
      await laptop.engine.sync();

      expect(await laptop.history.watchExperiments(_soupId).first, [
        experiment,
      ]);
      expect(
        await laptop.history.getVersionSnapshot(experiment.baseVersionId),
        _soup(),
      );
      expect(await laptop.recipes.watchRecipeIds().first, [_soupId]);

      await phone.history.deleteExperiment(experiment.id);
      await phone.engine.sync();
      await laptop.engine.sync();
      expect(await laptop.history.watchExperiments(_soupId).first, isEmpty);
    });
  });

  group(RecipeSnapshotJson, () {
    test('round-trips a snapshot', () {
      expect(
        RecipeSnapshotJson.decode(RecipeSnapshotJson.encode(_soup())),
        _soup(),
      );
    });

    test('is null for text it did not write', () {
      expect(RecipeSnapshotJson.decode('{'), isNull);
      expect(RecipeSnapshotJson.decode('[]'), isNull);
      expect(RecipeSnapshotJson.decode('{}'), isNull);
      expect(RecipeSnapshotJson.decode('{"recipe": {"title": "x"}}'), isNull);
    });
  });

  group('history codecs', () {
    test('wait for every required field', () {
      expect(RecipeVersionCodec().decode('v1', {'summary': ''}), isNull);
      expect(ExperimentCodec().decode('e1', {'notes': ''}), isNull);
    });
  });
}
