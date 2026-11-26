import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/grocery/grocery.dart';

import '../../../helpers/helpers.dart';
import '../../nutrition/fakes.dart' show FakeFoodRepository;
import '../fakes.dart';

typedef _F = GroceryFixtures;

void main() {
  const chili = RecipeId('chili');
  late FakeGroceryRepository groceries;
  late FakeRecipeRepository recipes;
  late FakeFoodRepository foods;

  // Fakes are made inside each test, not in setUp, so their streams run
  // in the test's fake-async zone and pumps deliver their events.
  Future<void> arrange() async {
    groceries = FakeGroceryRepository();
    recipes = FakeRecipeRepository();
    foods = FakeFoodRepository();
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
        foodRepositoryProvider.overrideWithValue(foods),
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

    testWidgets('picks lines without striking them through', (tester) async {
      await arrange();
      await openSheet(tester, chili);

      final rows = tester.widgetList<IngredientRow>(find.byType(IngredientRow));
      expect(rows.map((row) => row.checked), everyElement(isTrue));
      expect(
        rows.map((row) => row.checkStyle),
        everyElement(IngredientCheckStyle.select),
      );
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

    group('with items already on the list', () {
      Future<void> arrangeList() async {
        await arrange();
        await groceries.saveList(
          GroceryList(id: _F.listId, name: '', createdAt: DateTime.utc(2026)),
        );
        await groceries.saveItem(
          _F.item('x', name: 'Onion', quantity: Quantity(1)),
        );
        await groceries.saveItem(_F.item('y', name: 'beans'));
      }

      testWidgets('says what each line adds to', (tester) async {
        await arrangeList();
        await openSheet(tester, chili);

        expect(find.text('Adds to 1 on your list'), findsOneWidget);
        expect(find.text('Already on your list'), findsOneWidget);
        expect(
          find.text('2 combine with items already on your list'),
          findsOneWidget,
        );
      });

      testWidgets('counts only the lines that are included', (tester) async {
        await arrangeList();
        await openSheet(tester, chili);

        await tester.tap(find.text('onions'));
        await tester.pumpAndSettle();
        expect(
          find.text('1 combines with an item already on your list'),
          findsOneWidget,
        );

        await tester.tap(find.text('beans'));
        await tester.pumpAndSettle();
        expect(find.textContaining('combine'), findsNothing);
        // The hints stay, so the user can see why they left a line out.
        expect(find.text('Adds to 1 on your list'), findsOneWidget);
      });
    });

    testWidgets('says when what it adds to was worked out by weight', (
      tester,
    ) async {
      await arrange();
      await recipes.saveIngredientLine(
        _F.line(
          'c',
          recipeId: 'chili',
          name: 'sugar',
          quantity: Quantity(1),
          unit: Unit.tablespoon,
        ),
      );
      await groceries.saveList(
        GroceryList(id: _F.listId, name: '', createdAt: DateTime.utc(2026)),
      );
      await groceries.saveItem(
        _F.item('x', name: 'sugar', quantity: Quantity(1), unit: Unit.cup),
      );
      await groceries.saveItem(
        _F.item('y', name: 'sugar', quantity: Quantity(200), unit: Unit.gram),
      );
      await openSheet(tester, chili);

      expect(find.textContaining('Adds to about'), findsOneWidget);
    });

    testWidgets('shows no hints for a new list', (tester) async {
      await arrange();
      await openSheet(tester, chili);

      expect(find.textContaining('on your list'), findsNothing);
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
