import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/cooking/application/screen_awake.dart';
import 'package:sousvite/features/cooking/presentation/cooking_header.dart';
import 'package:sousvite/features/cooking/presentation/cooking_screen.dart';
import 'package:sousvite/features/cooking/presentation/cooking_step_page.dart';
import 'package:sousvite/features/cooking/presentation/timer_tray.dart';

import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/fake_user_recipe_prefs_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';
import '../../../helpers/helpers.dart';
import '../fake_screen_awake.dart';

void main() {
  const recipeId = RecipeId('r1');
  late FakeRecipeRepository recipes;
  late FakeScreenAwake screen;

  final flour = RecipeFixtures.line(
    'flour',
    quantity: Quantity(3, 4),
    unit: Unit.cup,
    name: 'flour',
  );
  final milk = RecipeFixtures.line('milk', name: 'milk');

  setUp(() {
    screen = FakeScreenAwake();
    recipes = FakeRecipeRepository()
      ..seed(
        recipe: RecipeFixtures.recipe(),
        lines: [flour, milk],
        stepSections: [RecipeFixtures.stepSection('bake', name: 'Bake')],
        steps: [
          RecipeFixtures.step('mix', text: 'Whisk the flour and milk.'),
          RecipeFixtures.step(
            'oven',
            sectionId: 'bake',
            text: 'Bake for 20 minutes.',
          ),
        ],
      );
  });

  List<Override> overrides() => [
    recipeRepositoryProvider.overrideWithValue(recipes),
    userRecipePrefsRepositoryProvider.overrideWithValue(
      FakeUserRecipePrefsRepository(),
    ),
    screenAwakeProvider.overrideWithValue(screen),
  ];

  Future<void> pumpCooking(WidgetTester tester) async {
    await tester.pumpApp(
      const CookingScreen(recipeId: recipeId),
      overrides: overrides(),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows one step in the cooking theme, screen on', (tester) async {
    await pumpCooking(tester);

    expect(find.text('Step 1 of 2'), findsOneWidget);
    expect(find.text('Whisk the flour and milk.'), findsOneWidget);
    expect(find.text('Bake for 20 minutes.'), findsNothing);
    final theme = Theme.of(tester.element(find.byType(CookingStepText)));
    expect(theme.colorScheme, AppColorSchemes.cookingLight);
    expect(screen.isOn, isTrue);

    await tester.pumpWidget(const SizedBox());
    expect(screen.isOn, isFalse);
  });

  testWidgets('moves with Next and Back, and by swiping', (tester) async {
    final builds = BuildCounter.start();
    await pumpCooking(tester);
    expect(find.text('Back'), findsOneWidget);
    builds.reset();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Bake · Step 2 of 2'), findsOneWidget);
    expect(find.text('Bake for 20 minutes.'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(builds.of<CookingScreen>(), 0);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 2'), findsOneWidget);

    await tester.fling(
      find.byType(CookingStepPage),
      const Offset(-400, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.text('Bake · Step 2 of 2'), findsOneWidget);
  });

  testWidgets('checks off this step’s ingredients, one row at a time', (
    tester,
  ) async {
    final builds = BuildCounter.start();
    await pumpCooking(tester);

    expect(find.text('Ingredients for this step'), findsOneWidget);
    expect(find.text('¾ cup'), findsOneWidget);
    builds.reset();

    await tester.tap(find.text('milk'));
    await tester.pumpAndSettle();

    final checkbox = tester.widget<Checkbox>(
      find.descendant(
        of: find.byKey(ValueKey(milk.id)),
        matching: find.byType(Checkbox),
      ),
    );
    expect(checkbox.value, isTrue);
    expect(builds.ofKey(ValueKey(milk.id)), 1);
    expect(builds.ofKey(ValueKey(flour.id)), 0);
    expect(builds.of<CookingStepText>(), 0);
  });

  testWidgets('starts a timer that stays in the tray on every step', (
    tester,
  ) async {
    await pumpCooking(tester);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('20 minutes'));
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.descendant(
        of: find.byType(TimerTray),
        matching: find.byType(TimerChip),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Back'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(TimerChip), findsOneWidget);

    await tester.tap(find.byType(TimerChip));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(TimerChip), findsNothing);
  });

  testWidgets('says when there are no steps', (tester) async {
    recipes = FakeRecipeRepository()..seed(recipe: RecipeFixtures.recipe());
    await pumpCooking(tester);
    expect(find.text('No steps yet'), findsOneWidget);
    expect(find.byType(CookingHeader), findsOneWidget);
  });

  testWidgets('shows ingredients beside the step on a landscape tablet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpCooking(tester);

    final step = tester.getTopLeft(find.text('Whisk the flour and milk.'));
    final ingredients = tester.getTopLeft(
      find.text('Ingredients for this step'),
    );
    expect(ingredients.dx, greaterThan(step.dx));
  });

  group('leaving', () {
    late List<String> visited;

    Future<GoRouter> pumpWithRouter(
      WidgetTester tester, {
      String initialLocation = '/recipes/r1',
    }) async {
      visited = [];
      final router = GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(
            path: '/recipes/r1',
            builder: (_, _) {
              visited.add('recipe');
              return const SizedBox();
            },
            routes: [
              GoRoute(
                path: 'cook',
                builder: (_, _) => const CookingScreen(recipeId: recipeId),
              ),
            ],
          ),
          GoRoute(
            path: '/cook',
            builder: (_, _) => const CookingScreen(recipeId: recipeId),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router, overrides: overrides());
      await tester.pumpAndSettle();
      return router;
    }

    testWidgets('closing keeps your place', (tester) async {
      final router = await pumpWithRouter(tester);
      unawaited(router.push('/recipes/r1/cook'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Close cooking mode'));
      await tester.pumpAndSettle();
      expect(find.byType(CookingScreen), findsNothing);

      unawaited(router.push('/recipes/r1/cook'));
      await tester.pumpAndSettle();
      expect(find.text('Bake · Step 2 of 2'), findsOneWidget);
    });

    testWidgets('done starts over next time', (tester) async {
      final router = await pumpWithRouter(tester);
      unawaited(router.push('/recipes/r1/cook'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('milk'));
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.byType(CookingScreen), findsNothing);

      unawaited(router.push('/recipes/r1/cook'));
      await tester.pumpAndSettle();
      expect(find.text('Step 1 of 2'), findsOneWidget);
    });

    testWidgets('closing without history goes to the recipe', (tester) async {
      await pumpWithRouter(tester, initialLocation: '/cook');
      expect(visited, isEmpty);
      await tester.tap(find.byTooltip('Close cooking mode'));
      await tester.pumpAndSettle();
      expect(visited, ['recipe']);
    });
  });
}
