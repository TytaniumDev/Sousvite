import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/grocery/presentation/grocery_entry_row.dart';
import 'package:sousvite/features/grocery/presentation/grocery_screen.dart';

import '../../../helpers/helpers.dart';
import '../fakes.dart';

typedef _F = GroceryFixtures;

void main() {
  late FakeGroceryRepository groceries;
  late FakeRecipeRepository recipes;

  // Fakes are made inside each test, not in setUp, so their streams run
  // in the test's fake-async zone and pumps deliver their events.
  Future<void> arrange() async {
    groceries = FakeGroceryRepository();
    recipes = FakeRecipeRepository();
    await recipes.saveRecipe(_F.recipe('chili', title: 'Chili'));
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpApp(
      const GroceryScreen(),
      overrides: [
        groceryRepositoryProvider.overrideWithValue(groceries),
        recipeRepositoryProvider.overrideWithValue(recipes),
      ],
    );
    await tester.pumpAndSettle();
  }

  Future<void> saveList() => groceries.saveList(
    GroceryList(id: _F.listId, name: '', createdAt: DateTime.utc(2026)),
  );

  group(GroceryScreen, () {
    testWidgets('shows an empty state with no list', (tester) async {
      await arrange();
      await pumpScreen(tester);

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('Your list is empty'), findsOneWidget);
    });

    testWidgets('shows an error with a retry', (tester) async {
      await arrange();
      await tester.pumpApp(
        const GroceryScreen(),
        overrides: [
          groceryRepositoryProvider.overrideWithValue(_FailingRepository()),
          recipeRepositoryProvider.overrideWithValue(recipes),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorState), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorState), findsOneWidget);
    });

    testWidgets('groups combined items by section, checked last', (
      tester,
    ) async {
      await arrange();
      await saveList();
      await groceries.saveItem(
        _F.item(
          'a',
          name: 'Onion',
          quantity: Quantity(2),
          storeSection: 'Produce',
          recipeId: const RecipeId('chili'),
        ),
      );
      await groceries.saveItem(
        _F.item('b', name: 'onion', quantity: Quantity(1)),
      );
      await groceries.saveItem(
        _F.item('c', name: 'milk', quantity: Quantity(1), unit: Unit.cup),
      );
      await groceries.saveItem(
        _F.item('d', name: 'milk', quantity: Quantity(200), unit: Unit.gram),
      );
      await groceries.saveItem(_F.item('eggs', checked: true));
      await pumpScreen(tester);

      expect(find.text('Produce'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
      expect(find.text('Checked'), findsOneWidget);
      expect(find.text('Onion'), findsOneWidget);
      expect(find.text('Chili'), findsOneWidget);
      expect(find.textContaining('+ 200'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('eggs')).dy,
        greaterThan(tester.getTopLeft(find.text('milk')).dy),
      );
    });

    testWidgets('checking one item rebuilds only its row', (tester) async {
      await arrange();
      await saveList();
      await groceries.saveItem(_F.item('apples', storeSection: 'Produce'));
      await groceries.saveItem(_F.item('pears', storeSection: 'Produce'));
      await groceries.saveItem(_F.item('bread', checked: true));
      final builds = BuildCounter.start();
      await pumpScreen(tester);
      builds.reset();

      await groceries.saveItem(
        _F.item('pears', storeSection: 'Produce').copyWith(name: 'Pears'),
      );
      await tester.pumpAndSettle();

      expect(builds.ofKey(const ValueKey('pears')), 1);
      expect(builds.ofKey(const ValueKey('apples')), 0);
      expect(builds.ofKey(const ValueKey('bread')), 0);
    });

    testWidgets('tapping a row checks it off', (tester) async {
      await arrange();
      await saveList();
      await groceries.saveItem(_F.item('apples'));
      await pumpScreen(tester);

      await tester.tap(find.text('apples'));
      await tester.pumpAndSettle();

      expect(groceries.items.values.single.checked, isTrue);
      expect(find.text('Checked'), findsOneWidget);
    });

    testWidgets('swiping removes an item, with undo', (tester) async {
      await arrange();
      await saveList();
      await groceries.saveItem(_F.item('apples'));
      await pumpScreen(tester);

      await tester.drag(find.byType(GroceryEntryRow), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(groceries.items, isEmpty);
      expect(find.text('apples removed'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(groceries.items, hasLength(1));
    });

    testWidgets('removes checked items from the menu, with undo', (
      tester,
    ) async {
      await arrange();
      await saveList();
      await groceries.saveItem(_F.item('apples'));
      await groceries.saveItem(_F.item('bread', checked: true));
      await pumpScreen(tester);

      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove checked items'));
      await tester.pumpAndSettle();

      expect(groceries.items.keys, [const GroceryItemId('apples')]);
      expect(find.byTooltip('More options'), findsNothing);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(groceries.items, hasLength(2));
    });

    testWidgets('adds an item by hand', (tester) async {
      await arrange();
      await pumpScreen(tester);

      await tester.tap(find.text('Add item'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Paper towels');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(groceries.items.values.single.name, 'Paper towels');
      expect(find.text('Paper towels'), findsOneWidget);
    });

    testWidgets('cancelling the dialog adds nothing', (tester) async {
      await arrange();
      await pumpScreen(tester);

      await tester.tap(find.text('Add item'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(groceries.items, isEmpty);
    });

    testWidgets('meets tap target and label guidelines', (tester) async {
      await arrange();
      final handle = tester.ensureSemantics();
      await saveList();
      await groceries.saveItem(_F.item('apples', checked: true));
      await pumpScreen(tester);

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });
  });
}

class _FailingRepository() extends FakeGroceryRepository {
  @override
  Stream<List<GroceryList>> watchLists() => Stream.error(StateError('broken'));
}
