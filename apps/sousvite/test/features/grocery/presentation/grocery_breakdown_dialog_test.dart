import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/grocery/presentation/grocery_breakdown_dialog.dart';
import 'package:sousvite/features/grocery/presentation/grocery_screen.dart';
import 'package:sousvite/features/recipe/recipe.dart';

import '../../../helpers/helpers.dart';
import '../../nutrition/fakes.dart' show FakeFoodRepository;
import '../fakes.dart';

typedef _F = GroceryFixtures;

void main() {
  const chili = RecipeId('chili');
  const cornbread = RecipeId('cornbread');
  late FakeGroceryRepository groceries;
  late FakeRecipeRepository recipes;
  late FakeFoodRepository foods;

  // Fakes are made inside each test, not in setUp, so their streams run
  // in the test's fake-async zone and pumps deliver their events.
  Future<void> arrange() async {
    groceries = FakeGroceryRepository();
    recipes = FakeRecipeRepository();
    foods = FakeFoodRepository();
    await recipes.saveRecipe(_F.recipe('chili', title: 'Chili'));
    await recipes.saveRecipe(_F.recipe('cornbread', title: 'Cornbread'));
    await groceries.saveList(
      GroceryList(id: _F.listId, name: '', createdAt: DateTime.utc(2026)),
    );
    await groceries.saveItem(
      _F.item(
        'a',
        name: 'sugar',
        quantity: Quantity(1, 4),
        unit: Unit.cup,
        recipeId: cornbread,
      ),
    );
    await groceries.saveItem(
      _F.item(
        'b',
        name: 'sugar',
        quantity: Quantity(2),
        unit: Unit.tablespoon,
        recipeId: chili,
      ),
    );
    await groceries.saveItem(
      _F.item('c', name: 'sugar', quantity: Quantity(200), unit: Unit.gram),
    );
    await groceries.saveItem(
      _F.item('salt', quantity: Quantity(1), unit: Unit.teaspoon),
    );
  }

  Future<GoRouter> pumpScreen(WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const GroceryScreen()),
        GoRoute(
          path: RecipeRoutes.path,
          builder: (_, state) =>
              Text('Recipe ${state.pathParameters['recipeId']}'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpRouterApp(
      router,
      overrides: [
        groceryRepositoryProvider.overrideWithValue(groceries),
        recipeRepositoryProvider.overrideWithValue(recipes),
        foodRepositoryProvider.overrideWithValue(foods),
      ],
    );
    await tester.pumpAndSettle();
    return router;
  }

  Future<void> openSugar(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(GroceryItemRow, 'sugar'),
        matching: find.byType(AmountText),
      ),
    );
    await tester.pumpAndSettle();
  }

  group(GroceryBreakdownDialog, () {
    testWidgets('shows the total and each recipe’s amount', (tester) async {
      await arrange();
      await pumpScreen(tester);
      await openSugar(tester);

      final dialog = find.byType(GroceryBreakdownDialog);
      Finder inDialog(String text) =>
          find.descendant(of: dialog, matching: find.text(text));
      expect(inDialog('sugar'), findsOneWidget);
      // Sugar's density puts the cups and grams together.
      expect(
        find.descendant(of: dialog, matching: find.textContaining('About ')),
        findsOneWidget,
      );
      expect(inDialog('In 2 recipes'), findsOneWidget);
      expect(inDialog('Cornbread'), findsOneWidget);
      expect(inDialog('¼\u00a0cup'), findsOneWidget);
      expect(inDialog('Chili'), findsOneWidget);
      expect(inDialog('2\u00a0Tbsp'), findsOneWidget);
      expect(inDialog('Added by hand'), findsOneWidget);
      expect(inDialog('200\u00a0g'), findsOneWidget);
      expect(
        tester.getTopLeft(inDialog('Cornbread')).dy,
        lessThan(tester.getTopLeft(inDialog('Chili')).dy),
      );
    });

    testWidgets('says what a recipe calls an item matched to the same food', (
      tester,
    ) async {
      await arrange();
      await groceries.saveItem(
        _F.item(
          'd',
          name: 'white sugar',
          quantity: Quantity(1),
          unit: Unit.teaspoon,
          recipeId: chili,
        ),
      );
      for (final lineId in ['chili-b', 'chili-d']) {
        await foods.saveMatch(
          NutritionMatch(
            id: NutritionMatchId(lineId),
            ingredientLineId: IngredientLineId(lineId),
            foodId: const FoodId('sugar'),
            source: NutritionSource.usda,
            gramWeight: 25,
          ),
        );
      }
      await pumpScreen(tester);
      await openSugar(tester);

      expect(find.text('white sugar'), findsOneWidget);
      expect(find.text('In 2 recipes'), findsOneWidget);
    });

    testWidgets('closes with Done or a tap outside it', (tester) async {
      await arrange();
      await pumpScreen(tester);

      await openSugar(tester);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.byType(GroceryBreakdownDialog), findsNothing);

      await openSugar(tester);
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.byType(GroceryBreakdownDialog), findsNothing);
    });

    testWidgets('opens a recipe when tapped', (tester) async {
      await arrange();
      await pumpScreen(tester);
      await openSugar(tester);

      await tester.tap(find.text('Chili'));
      await tester.pumpAndSettle();

      expect(find.byType(GroceryBreakdownDialog), findsNothing);
      expect(find.text('Recipe chili'), findsOneWidget);
    });

    testWidgets('leaves amounts of items added by hand plain', (tester) async {
      await arrange();
      await pumpScreen(tester);

      final salt = tester.widget<GroceryItemRow>(
        find.widgetWithText(GroceryItemRow, 'salt'),
      );
      expect(salt.onAmountTap, isNull);
      final sugar = tester.widget<GroceryItemRow>(
        find.widgetWithText(GroceryItemRow, 'sugar'),
      );
      expect(sugar.onAmountTap, isNotNull);
    });

    testWidgets('shows nothing once the item is gone', (tester) async {
      await arrange();
      await pumpScreen(tester);
      await openSugar(tester);

      for (final id in ['a', 'b', 'c']) {
        await groceries.deleteItem(GroceryItemId(id));
      }
      await tester.pumpAndSettle();

      expect(find.byType(GroceryBreakdownDialog), findsOneWidget);
      expect(find.text('In 2 recipes'), findsNothing);
    });
  });
}
