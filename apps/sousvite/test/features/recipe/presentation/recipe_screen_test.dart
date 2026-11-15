import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/recipe/presentation/recipe_header.dart';
import 'package:sousvite/features/recipe/presentation/recipe_ingredient_row.dart';
import 'package:sousvite/features/recipe/presentation/recipe_screen.dart';
import 'package:sousvite/features/recipe/presentation/steps_section.dart';

import '../../../helpers/fakes/fake_folder_repository.dart';
import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/fake_user_recipe_prefs_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';
import '../../../helpers/helpers.dart';
import '../../nutrition/fakes.dart' show FakeFoodRepository;

void main() {
  const recipeId = RecipeId('r1');
  late FakeRecipeRepository recipes;
  late FakeUserRecipePrefsRepository prefs;

  final flour = RecipeFixtures.line(
    'flour',
    sortKey: 'a',
    quantity: Quantity(3, 2),
    unit: Unit.cup,
    name: 'flour',
  ).copyWith(preparation: 'sifted');
  final milk = RecipeFixtures.line(
    'milk',
    sortKey: 'b',
    quantity: Quantity(2),
    quantityMax: Quantity(3),
    unit: Unit.tablespoon,
    name: 'milk',
  );
  final eggs = RecipeFixtures.line(
    'eggs',
    sectionId: 'topping',
    quantity: Quantity(2),
    name: 'eggs',
  );

  setUp(() {
    recipes = FakeRecipeRepository()
      ..seed(
        recipe: RecipeFixtures.recipe(servings: Quantity(4)).copyWith(
          sourceName: 'Grandma',
          prepTime: const Duration(minutes: 10),
          cookTime: const Duration(minutes: 20),
          totalTime: const Duration(minutes: 30),
          notes: 'Rest the batter.',
        ),
        ingredientSections: [
          RecipeFixtures.ingredientSection('topping', name: 'Topping'),
        ],
        lines: [flour, milk, eggs],
        stepSections: [RecipeFixtures.stepSection('prep', name: 'Prep')],
        steps: [
          RecipeFixtures.step('mix', sectionId: 'prep', text: 'Mix it.'),
          RecipeFixtures.step('cook', text: 'Cook it.'),
        ],
      );
    prefs = FakeUserRecipePrefsRepository();
  });

  Future<void> pumpRecipe(WidgetTester tester, {Widget? screen}) async {
    await tester.pumpApp(
      screen ?? const RecipeScreen(recipeId: recipeId),
      overrides: [
        recipeRepositoryProvider.overrideWithValue(recipes),
        userRecipePrefsRepositoryProvider.overrideWithValue(prefs),
        folderRepositoryProvider.overrideWithValue(FakeFolderRepository()),
        foodRepositoryProvider.overrideWithValue(FakeFoodRepository()),
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the name, details, ingredients, steps, and notes', (
    tester,
  ) async {
    await pumpRecipe(tester);

    expect(find.text('Oat pancakes'), findsOneWidget);
    expect(
      find.text('From Grandma · Prep 10 min · Cook 20 min · Total 30 min'),
      findsOneWidget,
    );
    expect(find.text('1 ½\u00a0cups'), findsOneWidget);
    expect(find.textContaining('sifted'), findsOneWidget);
    expect(find.textContaining('2–3\u00a0Tbsp milk'), findsOneWidget);
    expect(find.text('Topping'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Prep'), 100);
    expect(find.text('Prep'), findsOneWidget);
    expect(find.text('1 step'), findsOneWidget);

    // Loose steps come first, then each section, numbered through.
    final tiles = tester.widgetList<RecipeStepTile>(
      find.byType(RecipeStepTile),
    );
    expect(tiles.map((tile) => (tile.stepId.value, tile.number)), [
      ('cook', 1),
      ('mix', 2),
    ]);

    await tester.scrollUntilVisible(find.text('Rest the batter.'), 100);
    expect(find.text('Rest the batter.'), findsOneWidget);
  });

  testWidgets('scaling servings changes amounts and rebuilds only rows', (
    tester,
  ) async {
    final builds = BuildCounter.start();
    await pumpRecipe(tester);
    builds.reset();

    await tester.tap(find.byTooltip('More servings'));
    await tester.pumpAndSettle();

    expect(find.text('5\u00a0servings'), findsOneWidget);
    expect(find.text('1 ⅞\u00a0cups'), findsOneWidget);
    expect(builds.ofKey(ValueKey(flour.id)), 1);
    expect(builds.of<RecipeHeader>(), 0);
    expect(builds.of<RecipeStepTile>(), 0);

    await tester.tap(find.text('Back to the original amounts'));
    await tester.pumpAndSettle();
    expect(find.text('4\u00a0servings'), findsOneWidget);
    expect(find.text('1 ½\u00a0cups'), findsOneWidget);
  });

  testWidgets('switching to metric converts and is remembered', (tester) async {
    await pumpRecipe(tester);

    await tester.tap(find.text('Metric'));
    await tester.pumpAndSettle();

    expect(find.text('1 ½\u00a0cups'), findsNothing);
    expect(find.textContaining('\u00a0ml'), findsWidgets);
    expect(
      (await prefs.watchPrefs(recipeId).first)?.unitSystem,
      UnitSystem.metric,
    );
  });

  testWidgets('editing one line rebuilds only that row', (tester) async {
    final builds = BuildCounter.start();
    await pumpRecipe(tester);
    builds.reset();

    await recipes.saveIngredientLine(flour.copyWith(name: 'oat flour'));
    await tester.pumpAndSettle();

    expect(find.textContaining('oat flour'), findsOneWidget);
    expect(builds.ofKey(ValueKey(flour.id)), 1);
    expect(builds.ofKey(ValueKey(eggs.id)), 0);
    expect(builds.of<RecipeIngredientRow>(), 1);
    expect(builds.of<RecipeStepTile>(), 0);
  });

  testWidgets('says when the recipe is gone', (tester) async {
    await pumpRecipe(
      tester,
      screen: const RecipeScreen(recipeId: RecipeId('gone')),
    );
    expect(find.text('Recipe not found'), findsOneWidget);
    expect(find.byTooltip('More options'), findsNothing);
  });

  testWidgets('lays ingredients and steps side by side on wide windows', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpRecipe(tester);

    final ingredients = tester.getTopLeft(find.text('Ingredients'));
    final steps = tester.getTopLeft(find.text('Steps'));
    expect(ingredients.dy, steps.dy);
    expect(steps.dx, greaterThan(ingredients.dx));
  });

  group('navigation', () {
    late List<String> opened;

    Future<void> pumpWithRouter(WidgetTester tester) async {
      opened = [];
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const RecipeScreen(recipeId: recipeId),
            routes: [
              GoRoute(
                path: ':feature/:id',
                builder: (_, state) {
                  opened.add(state.uri.path);
                  return const SizedBox();
                },
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(
        router,
        overrides: [
          recipeRepositoryProvider.overrideWithValue(recipes),
          userRecipePrefsRepositoryProvider.overrideWithValue(prefs),
          folderRepositoryProvider.overrideWithValue(FakeFolderRepository()),
          foodRepositoryProvider.overrideWithValue(FakeFoodRepository()),
        ],
      );
      await tester.pumpAndSettle();
    }

    testWidgets('start cooking opens cooking mode', (tester) async {
      await pumpWithRouter(tester);
      await tester.tap(find.text('Start cooking'));
      await tester.pumpAndSettle();
      expect(opened, ['/cook/r1']);
    });

    testWidgets('all nutrients opens the nutrition screen', (tester) async {
      await pumpWithRouter(tester);
      await tester.scrollUntilVisible(find.text('All nutrients'), 100);
      await tester.ensureVisible(find.text('All nutrients'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All nutrients'));
      await tester.pumpAndSettle();
      expect(opened, ['/nutrition/r1']);
    });

    for (final (item, location) in [
      ('Edit recipe', '/editor/r1'),
      ('Experiments and history', '/history/r1'),
      ('Share', '/share/r1'),
    ]) {
      testWidgets('$item opens $location', (tester) async {
        await pumpWithRouter(tester);
        await tester.tap(find.byTooltip('More options'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(item));
        await tester.pumpAndSettle();
        expect(opened, [location]);
      });
    }

    testWidgets('add to grocery list opens the grocery sheet', (tester) async {
      await pumpWithRouter(tester);
      await tester.tap(find.text('Add to grocery list'));
      await tester.pumpAndSettle();
      expect(find.text('Add to list'), findsOneWidget);
    });

    testWidgets('folders opens the folders sheet', (tester) async {
      await pumpWithRouter(tester);
      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Folders'));
      await tester.pumpAndSettle();
      expect(
        find.text('No folders yet. Create one to sort your recipes.'),
        findsOneWidget,
      );
    });
  });
}
