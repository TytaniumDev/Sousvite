import 'package:domain/domain.dart';
import 'package:test/test.dart';

/// Serves one recipe's parts; every other call is unused here.
class _OneRecipeRepository(final RecipeSnapshot _snapshot)
    implements RecipeRepository {
  @override
  Future<Recipe?> getRecipe(RecipeId id) async =>
      id == _snapshot.recipe.id ? _snapshot.recipe : null;

  @override
  Stream<List<IngredientSection>> watchIngredientSections(RecipeId recipeId) =>
      Stream.value(_snapshot.ingredientSections);

  @override
  Stream<List<IngredientLine>> watchIngredientLines(RecipeId recipeId) =>
      Stream.value(_snapshot.ingredientLines);

  @override
  Stream<List<StepSection>> watchStepSections(RecipeId recipeId) =>
      Stream.value(_snapshot.stepSections);

  @override
  Stream<List<RecipeStep>> watchSteps(RecipeId recipeId) =>
      Stream.value(_snapshot.steps);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('RecipeSnapshots.getSnapshot', () {
    const recipeId = RecipeId('r1');
    final snapshot = RecipeSnapshot(
      recipe: Recipe(
        id: recipeId,
        title: 'Oatmeal',
        servings: Quantity(2),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
      ingredientLines: [
        const IngredientLine(
          id: IngredientLineId('l1'),
          recipeId: recipeId,
          rawText: 'Oats',
          sortKey: SortKey('a'),
        ),
      ],
      steps: [
        const RecipeStep(
          id: RecipeStepId('s1'),
          recipeId: recipeId,
          text: 'Cook.',
          sortKey: SortKey('a'),
        ),
      ],
    );
    final repository = _OneRecipeRepository(snapshot);

    test('reads the recipe with all its parts', () async {
      expect(await repository.getSnapshot(recipeId), snapshot);
    });

    test('is null for a recipe that does not exist', () async {
      expect(await repository.getSnapshot(const RecipeId('nope')), isNull);
    });
  });
}
