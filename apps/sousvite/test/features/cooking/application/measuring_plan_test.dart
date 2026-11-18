import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:measuring/measuring.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/cooking/application/measuring_plan.dart';

import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/fake_user_recipe_prefs_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';
import '../../settings/fakes.dart' show FakeMeasuringToolRepository;

void main() {
  const recipeId = RecipeId('r1');
  late ProviderContainer container;

  setUp(() {
    final recipes = FakeRecipeRepository()
      ..seed(
        recipe: RecipeFixtures.recipe(),
        lines: [
          RecipeFixtures.line(
            'salt',
            quantity: Quantity(3, 2),
            unit: Unit.teaspoon,
            name: 'kosher salt',
          ),
          RecipeFixtures.line(
            'milk',
            quantity: Quantity.one,
            unit: Unit.cup,
            name: 'milk',
          ),
          RecipeFixtures.line(
            'oil',
            quantity: Quantity(2),
            quantityMax: Quantity(3),
            unit: Unit.tablespoon,
            name: 'olive oil',
          ),
          RecipeFixtures.line(
            'beef',
            quantity: Quantity(500),
            unit: Unit.gram,
            name: 'beef',
          ),
          RecipeFixtures.line('pepper', rawText: 'Pepper to taste'),
        ],
      );
    container = ProviderContainer.test(
      overrides: [
        recipeRepositoryProvider.overrideWithValue(recipes),
        userRecipePrefsRepositoryProvider.overrideWithValue(
          FakeUserRecipePrefsRepository(),
        ),
        measuringToolRepositoryProvider.overrideWithValue(
          FakeMeasuringToolRepository(),
        ),
      ],
    );
  });

  Future<List<ToolUse>?> plan(String lineId) async {
    final provider = lineMeasuringPlanProvider(
      recipeId,
      IngredientLineId(lineId),
    );
    final subscription = container.listen(provider, (_, _) {});
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    return subscription.read();
  }

  test('measures 1 ½ tsp with one ½ Tbsp spoon', () async {
    expect(await plan('salt'), [
      ToolUse(Amount(Quantity(1, 2), Unit.tablespoon), 1),
    ]);
  });

  test('says nothing for an amount that is one of your tools', () async {
    expect(await plan('milk'), isNull);
  });

  test('says nothing for a range, a mass, or no amount', () async {
    expect(await plan('oil'), isNull);
    expect(await plan('beef'), isNull);
    expect(await plan('pepper'), isNull);
  });
}
