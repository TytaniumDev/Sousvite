import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/recipe/presentation/recipe_screen.dart';
import 'package:sousvite/features/recipe/presentation/smart_step_text.dart';

import '../../../helpers/fakes/fake_folder_repository.dart';
import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/fake_user_recipe_prefs_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';
import '../../../helpers/helpers.dart';
import '../../nutrition/fakes.dart' show FakeFoodRepository;

void main() {
  const recipeId = RecipeId('r1');
  late FakeRecipeRepository recipes;

  setUp(() {
    recipes = FakeRecipeRepository()
      ..seed(
        recipe: RecipeFixtures.recipe(servings: Quantity(4)),
        lines: [
          RecipeFixtures.line(
            'flour',
            sortKey: 'a',
            quantity: Quantity(3, 2),
            unit: Unit.cup,
            name: 'flour',
          ),
          RecipeFixtures.line(
            'thyme',
            sortKey: 'b',
            quantity: Quantity(2),
            quantityMax: Quantity(3),
            countWord: 'sprig',
            name: 'thyme',
          ),
        ],
        steps: [
          RecipeFixtures.step(
            'whisk',
            sortKey: 'a',
            text: 'Whisk in the flour.',
          ),
          RecipeFixtures.step('rest', sortKey: 'b', text: 'Let it rest.'),
          RecipeFixtures.step('top', sortKey: 'c', text: 'Top with thyme.'),
        ],
      );
  });

  Future<void> pumpRecipe(WidgetTester tester) async {
    await tester.pumpApp(
      const RecipeScreen(recipeId: recipeId),
      overrides: [
        recipeRepositoryProvider.overrideWithValue(recipes),
        userRecipePrefsRepositoryProvider.overrideWithValue(
          FakeUserRecipePrefsRepository(),
        ),
        folderRepositoryProvider.overrideWithValue(FakeFolderRepository()),
        foodRepositoryProvider.overrideWithValue(FakeFoodRepository()),
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('places amounts inline in the recipe steps', (tester) async {
    await pumpRecipe(tester);
    await tester.scrollUntilVisible(
      find.textContaining('Let it rest.'),
      100,
      scrollable: pageScrollable,
    );

    expect(find.textContaining('Whisk in 1 ½ cups flour.'), findsOneWidget);
    expect(find.textContaining('Let it rest.'), findsOneWidget);
    expect(find.textContaining('Top with 2–3 sprigs thyme.'), findsOneWidget);
  });

  testWidgets('scales amounts and rebuilds only steps that have one', (
    tester,
  ) async {
    // Tall enough that every step is built before counting, so scrolling
    // to one doesn't count as a rebuild.
    tester.setWindowWidth(400, height: 2000);
    final builds = BuildCounter.start();
    await pumpRecipe(tester);
    builds.reset();

    await tester.tap(find.byTooltip('More servings'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('Let it rest.'),
      100,
      scrollable: pageScrollable,
    );

    expect(find.textContaining('Whisk in 1 ⅞ cups flour.'), findsOneWidget);
    // The flour and thyme steps; "Let it rest." has no amount to scale.
    expect(builds.of<SmartStepText>(), 2);
  });
}
