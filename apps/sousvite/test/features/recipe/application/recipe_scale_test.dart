import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/recipe/application/recipe_data.dart';
import 'package:sousvite/features/recipe/application/recipe_scale.dart';
import 'package:sousvite/features/recipe/application/recipe_units.dart';
import 'package:sousvite/features/settings/settings.dart';

import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/fake_user_recipe_prefs_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';
import '../../settings/fakes.dart';

void main() {
  const recipeId = RecipeId('r1');
  const lineId = IngredientLineId('l1');
  late ProviderContainer container;

  setUp(() async {
    final repository = FakeRecipeRepository()
      ..seed(
        recipe: RecipeFixtures.recipe(servings: Quantity(4)),
        lines: [
          RecipeFixtures.line(
            'l1',
            quantity: Quantity(3, 4),
            quantityMax: Quantity(1),
            unit: Unit.cup,
          ),
          RecipeFixtures.line('l2', name: 'salt'),
          RecipeFixtures.line(
            'garlic',
            quantity: Quantity(6),
            countWord: 'clove',
            name: 'garlic',
          ),
        ],
      );
    container =
        ProviderContainer.test(
            overrides: [
              recipeRepositoryProvider.overrideWithValue(repository),
              userRecipePrefsRepositoryProvider.overrideWithValue(
                FakeUserRecipePrefsRepository(),
              ),
              appSettingsRepositoryProvider.overrideWithValue(
                FakeAppSettingsRepository(),
              ),
            ],
          )
          ..listen(recipeProvider(recipeId), (_, _) {})
          ..listen(jarredGarlicControllerProvider, (_, _) {})
          ..listen(ingredientLinesProvider(recipeId), (_, _) {});
    await container.read(recipeProvider(recipeId).future);
    await container.read(ingredientLinesProvider(recipeId).future);
  });

  RecipeScale scale() => container.read(recipeScaleProvider(recipeId).notifier);

  group(RecipeScale, () {
    test('starts at the recipe as written', () {
      expect(container.read(recipeScaleProvider(recipeId)), Quantity.one);
      expect(container.read(scaledServingsProvider(recipeId)), Quantity(4));
    });

    test('scales by a multiplier and ignores non-positive ones', () {
      scale().scaleBy(Quantity(2));
      expect(container.read(scaledServingsProvider(recipeId)), Quantity(8));

      scale()
        ..scaleBy(Quantity.zero)
        ..scaleBy(Quantity(-1));
      expect(container.read(recipeScaleProvider(recipeId)), Quantity(2));

      scale().reset();
      expect(container.read(recipeScaleProvider(recipeId)), Quantity.one);
    });

    test('scales to a number of servings', () {
      scale().scaleToServings(Quantity(6), from: Quantity(4));
      expect(container.read(recipeScaleProvider(recipeId)), Quantity(3, 2));
      expect(container.read(scaledServingsProvider(recipeId)), Quantity(6));
    });

    test('shows amounts as written until scaled or converted', () {
      expect(container.read(lineAmountProvider(recipeId, lineId)), (
        amount: Amount(Quantity(3, 4), Unit.cup),
        upTo: Amount(Quantity(1), Unit.cup),
      ));
      expect(
        container.read(
          lineAmountProvider(recipeId, const IngredientLineId('l2')),
        ),
        isNull,
      );
      expect(
        container.read(
          lineAmountProvider(recipeId, const IngredientLineId('gone')),
        ),
        isNull,
      );
    });

    test('scales line amounts exactly', () {
      scale().scaleToServings(Quantity(12), from: Quantity(4));
      expect(container.read(lineAmountProvider(recipeId, lineId)), (
        amount: Amount(Quantity(9, 4), Unit.cup),
        upTo: Amount(Quantity(3), Unit.cup),
      ));
    });

    test('converts line amounts to the chosen unit system', () async {
      container.listen(recipePrefsProvider(recipeId), (_, _) {});
      await container
          .read(recipeUnitSystemProvider(recipeId).notifier)
          .select(UnitSystem.metric);
      await container.pump();
      await container.pump();

      final shown = container.read(lineAmountProvider(recipeId, lineId));
      expect(shown?.amount.unit, Unit.milliliter);
      expect(shown?.upTo?.unit, Unit.milliliter);
    });
  });

  group('jarred garlic', () {
    const garlic = IngredientLineId('garlic');

    LineAmount? shown() => container.read(lineAmountProvider(recipeId, garlic));

    test('shows cloves until it is turned on', () {
      expect(shown(), (amount: Amount(Quantity(6), null), upTo: null));
    });

    test('shows cloves as rounded spoons of jarred garlic', () async {
      await container.read(jarredGarlicControllerProvider.notifier).toggle();

      // 6 cloves are 3 tsp, which rounds to 1 Tbsp.
      expect(shown(), (
        amount: const Amount(Quantity.one, Unit.tablespoon),
        upTo: null,
      ));

      scale().scaleBy(Quantity(1, 2));
      expect(shown(), (
        amount: Amount(Quantity(3, 2), Unit.teaspoon),
        upTo: null,
      ));
    });

    test('leaves other lines as they are', () async {
      await container.read(jarredGarlicControllerProvider.notifier).toggle();

      expect(container.read(lineAmountProvider(recipeId, lineId)), (
        amount: Amount(Quantity(3, 4), Unit.cup),
        upTo: Amount(Quantity(1), Unit.cup),
      ));
    });

    test('converts jarred garlic to the chosen unit system', () async {
      container.listen(recipePrefsProvider(recipeId), (_, _) {});
      await container.read(jarredGarlicControllerProvider.notifier).toggle();
      await container
          .read(recipeUnitSystemProvider(recipeId).notifier)
          .select(UnitSystem.metric);
      await container.pump();
      await container.pump();

      expect(shown()?.amount.unit, Unit.milliliter);
    });
  });

  test('ignores a recipe with no servings to scale from', () {
    container
        .read(recipeScaleProvider(recipeId).notifier)
        .scaleToServings(Quantity(2), from: Quantity.zero);
    expect(container.read(recipeScaleProvider(recipeId)), Quantity.one);
  });

  test('has no scaled servings before the recipe loads', () {
    final empty = ProviderContainer.test(
      overrides: [
        recipeRepositoryProvider.overrideWithValue(FakeRecipeRepository()),
      ],
    );
    expect(empty.read(scaledServingsProvider(recipeId)), isNull);
  });
}
