import 'package:clock/clock.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/cooking/application/checked_ingredients.dart';
import 'package:sousvite/features/cooking/application/cooking_steps.dart';
import 'package:sousvite/features/cooking/application/cooking_timers.dart';
import 'package:sousvite/features/cooking/application/step_ingredients.dart';

import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';

void main() {
  const recipeId = RecipeId('r1');
  const flour = IngredientLineId('flour');
  const milk = IngredientLineId('milk');
  late FakeRecipeRepository recipes;
  late ProviderContainer container;

  setUp(() {
    recipes = FakeRecipeRepository()
      ..seed(
        recipe: RecipeFixtures.recipe(),
        lines: [
          RecipeFixtures.line(
            'flour',
            quantity: Quantity(2),
            unit: Unit.cup,
            name: 'flour',
          ),
          RecipeFixtures.line(
            'milk',
            quantity: Quantity.one,
            unit: Unit.cup,
            name: 'milk',
          ),
          RecipeFixtures.line('note', rawText: 'Salt to taste'),
        ],
        stepSections: [RecipeFixtures.stepSection('prep', name: 'Prep')],
        steps: [
          RecipeFixtures.step(
            'whisk',
            sectionId: 'prep',
            text: 'Whisk the flour and milk.',
          ),
          RecipeFixtures.step('rest', text: 'Let it rest.'),
        ],
      );
    container = ProviderContainer.test(
      overrides: [recipeRepositoryProvider.overrideWithValue(recipes)],
    );
  });

  Future<T> settle<T>(T Function() read) async {
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    return read();
  }

  test('steps run loose steps first, then sections, with progress', () async {
    container.listen(cookingProgressProvider(recipeId), (_, _) {});
    final steps = await settle(
      () => container.read(cookingStepsProvider(recipeId)).value,
    );
    expect(steps?.map((step) => step.stepId.value), ['rest', 'whisk']);

    final progress = container.read(cookingProgressProvider(recipeId));
    expect(progress?.stepNumber, 1);
    expect(progress?.stepCount, 2);
    expect(progress?.sectionId, isNull);

    container.read(cookingPositionProvider(recipeId).notifier).goTo(9);
    expect(
      container.read(cookingProgressProvider(recipeId))?.sectionId,
      const StepSectionId('prep'),
    );

    container.read(cookingPositionProvider(recipeId).notifier).goTo(-1);
    expect(container.read(cookingPositionProvider(recipeId)), 0);
    container.read(cookingPositionProvider(recipeId).notifier)
      ..goTo(1)
      ..reset();
    expect(container.read(cookingPositionProvider(recipeId)), 0);
  });

  test('progress is null without steps', () async {
    recipes.seed(recipe: RecipeFixtures.recipe(id: 'empty'));
    const empty = RecipeId('empty');
    container.listen(cookingProgressProvider(empty), (_, _) {});
    expect(
      await settle(() => container.read(cookingProgressProvider(empty))),
      isNull,
    );
  });

  test('a step uses the lines whose amounts it places', () async {
    container
      ..listen(
        stepIngredientIdsProvider(recipeId, const RecipeStepId('whisk')),
        (_, _) {},
      )
      ..listen(
        stepIngredientIdsProvider(recipeId, const RecipeStepId('rest')),
        (_, _) {},
      );
    expect(
      await settle(
        () => container.read(
          stepIngredientIdsProvider(recipeId, const RecipeStepId('whisk')),
        ),
      ),
      [flour, milk],
    );
    expect(
      container.read(
        stepIngredientIdsProvider(recipeId, const RecipeStepId('rest')),
      ),
      isEmpty,
    );
  });

  test('checks ingredients off and clears them', () {
    final checked = container.read(
      checkedIngredientsProvider(recipeId).notifier,
    );
    container.listen(isIngredientCheckedProvider(recipeId, flour), (_, _) {});

    checked.setChecked(flour, checked: true);
    expect(container.read(isIngredientCheckedProvider(recipeId, flour)), true);
    checked.setChecked(flour, checked: false);
    expect(container.read(isIngredientCheckedProvider(recipeId, flour)), false);

    checked
      ..setChecked(milk, checked: true)
      ..clear();
    expect(container.read(checkedIngredientsProvider(recipeId)), isEmpty);
  });

  test('starts and stops timers', () {
    final startedAt = DateTime.utc(2026, 11, 15, 18);
    final key = timerKey(const RecipeStepId('rest'), 0);
    container.listen(timerStartedAtProvider(recipeId, key), (_, _) {});

    withClock(Clock.fixed(startedAt), () {
      container
          .read(cookingTimersProvider(recipeId).notifier)
          .start(key, label: '20 min', duration: const Duration(minutes: 20));
    });
    expect(container.read(timerStartedAtProvider(recipeId, key)), startedAt);
    expect(
      container.read(cookingTimersProvider(recipeId))[key]?.label,
      '20 min',
    );

    container.read(cookingTimersProvider(recipeId).notifier).stop(key);
    expect(container.read(timerStartedAtProvider(recipeId, key)), isNull);
  });
}
