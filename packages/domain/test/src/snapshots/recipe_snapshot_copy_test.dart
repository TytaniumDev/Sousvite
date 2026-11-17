import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group('RecipeSnapshotCopy', () {
    final created = DateTime.utc(2026, 11, 16);
    const recipeId = RecipeId('r1');
    final source = RecipeSnapshot(
      recipe: Recipe(
        id: recipeId,
        title: 'Soup',
        servings: Quantity(4),
        createdAt: created,
        updatedAt: created,
      ),
      ingredientSections: const [
        IngredientSection(
          id: IngredientSectionId('is1'),
          recipeId: recipeId,
          name: 'Garnish',
          sortKey: SortKey('a'),
        ),
      ],
      ingredientLines: const [
        IngredientLine(
          id: IngredientLineId('l1'),
          recipeId: recipeId,
          rawText: 'salt',
          sortKey: SortKey('a'),
        ),
        IngredientLine(
          id: IngredientLineId('l2'),
          recipeId: recipeId,
          rawText: 'basil',
          sortKey: SortKey('b'),
          sectionId: IngredientSectionId('is1'),
        ),
      ],
      stepSections: const [
        StepSection(
          id: StepSectionId('ss1'),
          recipeId: recipeId,
          name: 'Prep',
          sortKey: SortKey('a'),
        ),
      ],
      steps: const [
        RecipeStep(
          id: RecipeStepId('t1'),
          recipeId: recipeId,
          text: 'Chop.',
          sortKey: SortKey('a'),
          sectionId: StepSectionId('ss1'),
        ),
      ],
    );

    test('gives every part a new id under the new recipe', () {
      var next = 0;
      final copy = source.copyAs(
        const RecipeId('r2'),
        newId: () => 'n${next++}',
      );

      expect(copy.recipe, source.recipe.copyWith(id: const RecipeId('r2')));
      expect(
        copy.ingredientSections.single.id,
        const IngredientSectionId('n0'),
      );
      expect(copy.stepSections.single.id, const StepSectionId('n1'));
      expect(copy.ingredientLines.map((line) => line.id.value), ['n2', 'n3']);
      expect(copy.ingredientLines.map((line) => line.sectionId), [
        null,
        const IngredientSectionId('n0'),
      ]);
      expect(copy.steps.single.id, const RecipeStepId('n4'));
      expect(copy.steps.single.sectionId, const StepSectionId('n1'));
      expect(
        {
          ...copy.ingredientSections.map((part) => part.recipeId),
          ...copy.ingredientLines.map((part) => part.recipeId),
          ...copy.stepSections.map((part) => part.recipeId),
          ...copy.steps.map((part) => part.recipeId),
        },
        {const RecipeId('r2')},
      );
      expect(copy.ingredientLines.last.rawText, 'basil');
    });
  });
}
