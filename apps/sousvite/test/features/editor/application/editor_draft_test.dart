import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/editor/application/editor_draft.dart';
import 'package:sousvite/features/editor/application/editor_outline.dart';
import 'package:sousvite/features/editor/application/recipe_copies.dart';

import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';

void main() {
  const recipeId = RecipeId('r1');
  const flour = IngredientLineId('flour');
  late FakeRecipeRepository recipes;
  late ProviderContainer container;

  setUp(() {
    recipes = FakeRecipeRepository()
      ..seed(
        recipe: RecipeFixtures.recipe(),
        ingredientSections: [
          RecipeFixtures.ingredientSection('sauce', name: 'Sauce'),
        ],
        lines: [
          RecipeFixtures.line('flour', sortKey: 'a', name: 'flour'),
          RecipeFixtures.line('milk', sortKey: 'b', name: 'milk'),
          RecipeFixtures.line('salt', sectionId: 'sauce', name: 'salt'),
        ],
        stepSections: [
          RecipeFixtures.stepSection('prep', sortKey: 'a', name: 'Prep'),
          RecipeFixtures.stepSection('cook', sortKey: 'b', name: 'Cook'),
          RecipeFixtures.stepSection('serve', sortKey: 'c', name: 'Serve'),
        ],
        steps: [RecipeFixtures.step('mix', sectionId: 'prep')],
      );
    container = ProviderContainer.test(
      overrides: [recipeRepositoryProvider.overrideWithValue(recipes)],
    );
  });

  /// Loads the draft for [id] and returns its notifier.
  Future<EditorDraft> load([RecipeId id = recipeId]) {
    container.listen(editorDraftProvider(id), (_, _) {});
    return container
        .read(editorDraftProvider(id).future)
        .then((_) => container.read(editorDraftProvider(id).notifier));
  }

  RecipeSnapshot draft([RecipeId id = recipeId]) =>
      container.read(editorDraftProvider(id)).requireValue.draft;

  bool hasChanges([RecipeId id = recipeId]) =>
      container.read(editorHasChangesProvider(id));

  test('loads a saved recipe without changes', () async {
    await load();
    expect(draft().ingredientLines, hasLength(3));
    expect(container.read(editorIsNewProvider(recipeId)), isFalse);
    expect(hasChanges(), isFalse);
  });

  test('starts a new recipe with a Prep section', () async {
    const id = RecipeId('new');
    final editor = await load(id);
    expect(container.read(editorIsNewProvider(id)), isTrue);
    expect(draft(id).stepSections.single.name, 'Prep');
    expect(hasChanges(id), isFalse);

    editor.setTitle('Soup');
    expect(hasChanges(id), isTrue);
  });

  test('edits the recipe fields', () async {
    final editor = await load()
      ..setTitle('Crepes')
      ..setServings(Quantity(2))
      ..setServings(Quantity.zero)
      ..setTotalTime(const Duration(minutes: 30))
      ..setNotes('Rest the batter.');
    expect(draft().recipe.title, 'Crepes');
    expect(draft().recipe.servings, Quantity(2));
    expect(draft().recipe.totalTime, const Duration(minutes: 30));
    expect(draft().recipe.notes, 'Rest the batter.');
    expect(hasChanges(), isTrue);
    editor.setTitle('Oat pancakes');
  });

  test('adds pasted lines after a line, in order, parsed', () async {
    final editor = await load();
    final added = editor.addLines(['eggs', 'butter'], afterLineId: flour);
    expect(added, hasLength(2));

    final names = draft().ingredientLines
        .where((l) => l.sectionId == null)
        .map((l) => l.name);
    expect(names, ['flour', 'eggs', 'butter', 'milk']);

    editor.addLines(['pepper'], sectionId: const IngredientSectionId('sauce'));
    expect(
      container.read(
        editorLineIdsProvider(recipeId, const IngredientSectionId('sauce')),
      ),
      hasLength(2),
    );
  });

  test('sets a line through the parser and removes lines', () async {
    final editor = await load()
      ..setLineText(flour, '  rye flour ');
    final line = container.read(editorLineProvider(recipeId, flour));
    expect(line?.rawText, '  rye flour ');
    expect(line?.name, 'rye flour');

    editor.removeLine(flour);
    expect(container.read(editorLineProvider(recipeId, flour)), isNull);
  });

  test('splits a line into amount, unit, name, and preparation', () async {
    (await load()).setLineText(flour, '1 ½ cups rye flour, sifted');
    final line = container.read(editorLineProvider(recipeId, flour))!;
    expect(line.quantity, Quantity(3, 2));
    expect(line.unit, Unit.cup);
    expect(line.name, 'rye flour');
    expect(line.preparation, 'sifted');
  });

  test(
    'a pasted heading starts a new section for the lines after it',
    () async {
      final editor = await load();
      editor.addLines(['eggs', 'For the glaze:', 'sugar'], afterLineId: flour);

      final glaze = draft().ingredientSections.last;
      expect(glaze.name, 'Glaze');
      expect(
        container.read(editorLineIdsProvider(recipeId, null)),
        hasLength(3),
      );
      final glazeLines = draft().ingredientLines.where(
        (l) => l.sectionId == glaze.id,
      );
      expect(glazeLines.single.name, 'sugar');
    },
  );

  test('keeps a size in the name', () async {
    (await load()).setLineText(flour, '1 large egg');
    expect(
      container.read(editorLineProvider(recipeId, flour))?.name,
      'large egg',
    );
  });

  test('adds, renames, and removes ingredient sections', () async {
    final editor = await load();
    final id = editor.addIngredientSection('Topping')!;
    editor.renameIngredientSection(id, 'Glaze');
    expect(draft().ingredientSections.last.name, 'Glaze');

    editor.removeIngredientSection(const IngredientSectionId('sauce'));
    expect(container.read(editorIngredientSectionIdsProvider(recipeId)), [id]);
    expect(draft().ingredientLines.map((l) => l.name), ['flour', 'milk']);
  });

  test('edits steps and step sections', () async {
    final editor = await load();
    final stepId = editor.addStep(sectionId: const StepSectionId('cook'))!;
    editor.setStepText(stepId, 'Cook it.');
    expect(
      container.read(
        editorStepIdsProvider(recipeId, const StepSectionId('cook')),
      ),
      [stepId],
    );

    final sectionId = editor.addStepSection('Rest')!;
    editor.renameStepSection(sectionId, 'Chill');
    expect(draft().stepSections.last.name, 'Chill');

    editor
      ..removeStep(stepId)
      ..removeStepSection(const StepSectionId('prep'));
    expect(draft().steps, isEmpty);
  });

  test('moving a step section rekeys only that section', () async {
    final editor = await load()
      ..moveStepSection(2, 0);
    expect(container.read(editorStepSectionIdsProvider(recipeId)), const [
      StepSectionId('serve'),
      StepSectionId('prep'),
      StepSectionId('cook'),
    ]);
    expect(draft().stepSections[1].sortKey, const SortKey('a'));
    expect(draft().stepSections[2].sortKey, const SortKey('b'));

    editor
      ..moveStepSection(0, 2)
      ..moveStepSection(1, 1);
    expect(
      container.read(editorStepSectionIdsProvider(recipeId)).last,
      const StepSectionId('serve'),
    );
  });

  test('saves in one write, deleting what was removed', () async {
    final editor = await load()
      ..setTitle('  Crepes ')
      ..removeLine(flour)
      ..removeIngredientSection(const IngredientSectionId('sauce'))
      ..removeStepSection(const StepSectionId('prep'))
      ..addLines([' '])
      ..addStep();
    recipes.writes.clear();

    expect(await editor.save(), isTrue);
    expect(recipes.writes, [
      ('delete', flour),
      ('delete', const IngredientLineId('salt')),
      ('delete', const IngredientSectionId('sauce')),
      ('delete', const RecipeStepId('mix')),
      ('delete', const StepSectionId('prep')),
      isA<RecipeSnapshot>(),
    ]);
    expect(recipes.recipeById(recipeId)?.title, 'Crepes');
    expect(recipes.linesOf(recipeId).map((l) => l.name), ['milk']);
    expect(hasChanges(), isFalse);
  });

  test('does not save without a name', () async {
    final editor = await load(const RecipeId('new'));
    expect(await editor.save(), isFalse);
    expect(recipes.recipeById(const RecipeId('new')), isNull);
  });

  test('a new recipe saves without deleting anything', () async {
    const id = RecipeId('new');
    final editor = await load(id)
      ..setTitle('Soup');
    expect(await editor.save(), isTrue);
    expect(recipes.writes.last, isA<RecipeSnapshot>());
    expect(container.read(editorIsNewProvider(id)), isFalse);
  });

  group(RecipeCopies, () {
    test('duplicates with new ids, then deletes and restores', () async {
      await load();
      final source = draft();
      final copies = container.read(recipeCopiesProvider);

      final copyId = await copies.duplicate(source, title: 'Copy');
      expect(copyId, isNot(recipeId));
      expect(recipes.recipeById(copyId)?.title, 'Copy');
      final lines = recipes.linesOf(copyId);
      expect(lines, hasLength(3));
      expect(lines.map((l) => l.id), isNot(contains(flour)));
      expect(lines.last.sectionId, isNot(const IngredientSectionId('sauce')));
      expect(recipes.stepsOf(copyId).single.sectionId, isNotNull);

      await copies.delete(recipeId);
      expect(recipes.recipeById(recipeId), isNull);
      await copies.restore(source);
      expect(recipes.recipeById(recipeId), isNotNull);
    });
  });
}
