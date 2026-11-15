import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/recipe/application/recipe_data.dart';
import 'package:sousvite/features/recipe/application/recipe_units.dart';

import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/fake_user_recipe_prefs_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';

void main() {
  const recipeId = RecipeId('r1');
  late FakeUserRecipePrefsRepository prefs;
  late ProviderContainer container;

  setUp(() {
    prefs = FakeUserRecipePrefsRepository();
    container = ProviderContainer.test(
      overrides: [
        recipeRepositoryProvider.overrideWithValue(
          FakeRecipeRepository()
            ..seed(recipe: RecipeFixtures.recipe(servings: Quantity(4))),
        ),
        userRecipePrefsRepositoryProvider.overrideWithValue(prefs),
      ],
    );
  });

  Future<void> settle() async {
    for (var i = 0; i < 3; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  group(RecipeUnitSystem, () {
    test('shows amounts as written by default', () {
      expect(
        container.read(recipeUnitSystemProvider(recipeId)),
        UnitSystem.original,
      );
    });

    test('remembers the choice, keeping other prefs', () async {
      await prefs.savePrefs(
        UserRecipePrefs(recipeId: recipeId, servings: Quantity(3)),
      );
      container.listen(recipeUnitSystemProvider(recipeId), (_, _) {});
      await settle();

      await container
          .read(recipeUnitSystemProvider(recipeId).notifier)
          .select(UnitSystem.metric);
      await settle();

      expect(
        container.read(recipeUnitSystemProvider(recipeId)),
        UnitSystem.metric,
      );
      expect(
        await prefs.watchPrefs(recipeId).first,
        UserRecipePrefs(
          recipeId: recipeId,
          servings: Quantity(3),
          unitSystem: UnitSystem.metric,
        ),
      );
    });

    test("starts new prefs from the recipe's servings", () async {
      container
        ..listen(recipeProvider(recipeId), (_, _) {})
        ..listen(recipeUnitSystemProvider(recipeId), (_, _) {});
      await settle();

      await container
          .read(recipeUnitSystemProvider(recipeId).notifier)
          .select(UnitSystem.us);

      expect((await prefs.watchPrefs(recipeId).first)?.servings, Quantity(4));
    });

    test('does nothing before the recipe loads', () async {
      await container
          .read(recipeUnitSystemProvider(recipeId).notifier)
          .select(UnitSystem.us);
      expect(await prefs.watchPrefs(recipeId).first, isNull);
    });
  });
}
