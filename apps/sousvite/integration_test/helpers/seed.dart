import 'package:domain/domain.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:uuid/uuid.dart';

import 'e2e_device.dart';

/// Saves a two-line recipe called [title] on [device], as if typed in,
/// and returns its id.
Future<RecipeId> seedRecipe(E2eDevice device, String title) async {
  String newId() => const Uuid().v4();
  final id = RecipeId(newId());
  final now = DateTime.now().toUtc();
  await device.container
      .read(recipeRepositoryProvider)
      .saveSnapshot(
        RecipeSnapshot(
          recipe: Recipe(
            id: id,
            title: title,
            servings: Quantity(2),
            createdAt: now,
            updatedAt: now,
          ),
          ingredientLines: [
            IngredientLine(
              id: IngredientLineId(newId()),
              recipeId: id,
              rawText: '2 slices bread',
              sortKey: const SortKey('a'),
              quantity: Quantity(2),
              name: 'bread',
            ),
          ],
          steps: [
            RecipeStep(
              id: RecipeStepId(newId()),
              recipeId: id,
              text: 'Toast the bread.',
              sortKey: const SortKey('a'),
            ),
          ],
        ),
      );
  return id;
}

/// Renames [recipeId] on [device], as an edit there would.
Future<void> renameRecipe(
  E2eDevice device,
  RecipeId recipeId,
  String title,
) async {
  final recipes = device.container.read(recipeRepositoryProvider);
  final recipe = (await recipes.getRecipe(recipeId))!;
  await recipes.saveRecipe(
    recipe.copyWith(title: title, updatedAt: DateTime.now().toUtc()),
  );
}

/// [recipeId]'s title on [device], or null when it isn't there.
Future<String?> titleOn(E2eDevice device, RecipeId recipeId) async =>
    (await device.container.read(recipeRepositoryProvider).getRecipe(recipeId))
        ?.title;
