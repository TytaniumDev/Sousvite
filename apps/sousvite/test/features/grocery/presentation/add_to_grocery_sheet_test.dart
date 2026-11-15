import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/grocery/grocery.dart';

import '../../../helpers/helpers.dart';
import '../fakes.dart';

typedef _F = GroceryFixtures;

void main() {
  const chili = RecipeId('chili');
  late FakeGroceryRepository groceries;
  late FakeRecipeRepository recipes;

  // Fakes are made inside each test, not in setUp, so their streams run
  // in the test's fake-async zone and pumps deliver their events.
  Future<void> arrange() async {
    groceries = FakeGroceryRepository();
    recipes = FakeRecipeRepository();
    await recipes.saveIngredientLine(
      _F.line('a', recipeId: 'chili', name: 'onions', quantity: Quantity(2)),
    );
    await recipes.saveIngredientLine(
      _F.line(
        'b',
        recipeId: 'chili',
        name: 'beans',
        quantity: Quantity(3, 2),
        unit: Unit.cup,
      ),
    );
  }

  Future<void> openSheet(WidgetTester tester, RecipeId recipeId) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showAddToGrocerySheet(context, recipeId),
            child: const Text('open'),
          ),
        ),
      ),
      overrides: [
        groceryRepositoryProvider.overrideWithValue(groceries),
        recipeRepositoryProvider.overrideWithValue(recipes),
      ],
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('showAddToGrocerySheet', () {
    testWidgets('adds every line by default', (tester) async {
      await arrange();
      await openSheet(tester, chili);

      expect(find.text('Add to grocery list'), findsOneWidget);
      expect(find.textContaining('cups'), findsOneWidget);
      await tester.tap(find.text('Add to list'));
      await tester.pumpAndSettle();

      expect(groceries.items.values.map((item) => item.name), [
        'onions',
        'beans',
      ]);
      expect(find.text('Added to grocery list'), findsOneWidget);
      expect(find.text('Add to list'), findsNothing);
    });

    testWidgets('leaves out unchecked lines, rebuilding only that row', (
      tester,
    ) async {
      await arrange();
      await openSheet(tester, chili);
      final builds = BuildCounter.start();

      await tester.tap(find.text('onions'));
      await tester.pumpAndSettle();

      expect(builds.ofKey(const ValueKey(IngredientLineId('a'))), 1);
      expect(builds.ofKey(const ValueKey(IngredientLineId('b'))), 0);

      await tester.tap(find.text('Add to list'));
      await tester.pumpAndSettle();

      expect(groceries.items.values.single.name, 'beans');
    });

    testWidgets('says so when the recipe has no ingredients', (tester) async {
      await arrange();
      await openSheet(tester, const RecipeId('empty'));

      expect(find.text('This recipe has no ingredients yet.'), findsOneWidget);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });
}
