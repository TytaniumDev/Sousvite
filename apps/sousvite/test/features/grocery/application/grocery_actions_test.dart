import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/grocery/application/grocery_actions.dart';
import 'package:sousvite/features/grocery/application/grocery_ids.dart';

import '../fakes.dart';

typedef _F = GroceryFixtures;

void main() {
  group(GroceryActions, () {
    late FakeGroceryRepository repository;
    late GroceryActions actions;
    final now = DateTime.utc(2026, 11, 14);

    setUp(() {
      repository = FakeGroceryRepository();
      var next = 0;
      actions = GroceryActions(
        repository: repository,
        ids: GroceryIds(newId: () => 'id${next++}', nowMicros: () => 0),
        now: () => now,
      );
    });

    test('adds recipe lines to a new list, keeping their source', () async {
      const soup = RecipeId('soup');
      final onion = _F.line(
        'l1',
        recipeId: 'soup',
        name: 'onion',
        quantity: Quantity(2),
      );
      final water = _F.line('l2', recipeId: 'soup');
      final garlic = _F.line(
        'l3',
        recipeId: 'soup',
        name: 'garlic',
        quantity: Quantity(3),
        countWord: 'clove',
      );

      await actions.addFromRecipe(soup, [onion, water, garlic]);

      final list = repository.lists.values.single;
      expect(list.createdAt, now);
      final items = repository.items.values.toList();
      expect(items.map((item) => item.name), [
        'onion',
        water.rawText,
        'garlic',
      ]);
      expect(items.last.countWord, 'clove');
      expect(items.first.quantity, Quantity(2));
      expect(items.first.sourceRecipeId, soup);
      expect(items.first.sourceIngredientLineId, onion.id);
      expect(items.first.storeSection, StoreSection.produce.name);
      expect(items.every((item) => item.listId == list.id), isTrue);
    });

    test('adds to the oldest existing list', () async {
      final older = GroceryList(
        id: const GroceryListId('older'),
        name: '',
        createdAt: DateTime.utc(2025),
      );
      await repository.saveList(
        GroceryList(
          id: const GroceryListId('newer'),
          name: '',
          createdAt: DateTime.utc(2026),
        ),
      );
      await repository.saveList(older);

      await actions.addManualItem('  paper towels ');

      expect(repository.lists, hasLength(2));
      final item = repository.items.values.single;
      expect(item.listId, older.id);
      expect(item.name, 'paper towels');
      expect(item.storeSection, StoreSection.other.name);
      expect(item.sourceRecipeId, isNull);
    });

    test('ignores blank manual items and empty selections', () async {
      await actions.addManualItem('   ');
      await actions.addFromRecipe(const RecipeId('soup'), const []);

      expect(repository.lists, isEmpty);
      expect(repository.items, isEmpty);
    });

    test('checks off only the items that change', () async {
      final a = _F.item('a', checked: true);
      final b = _F.item('b');
      await repository.saveItem(a);
      await repository.saveItem(b);

      await actions.setChecked([a, b], checked: true);

      expect(repository.items.values.every((item) => item.checked), isTrue);
    });

    test('removes items and restores them for undo', () async {
      final a = _F.item('a');
      await repository.saveItem(a);

      await actions.remove([a]);
      expect(repository.items, isEmpty);

      await actions.restore([a]);
      expect(repository.items.values, [a]);
    });

    test('separates items from the same food, and restores them', () async {
      final sugar = _F.item('a', name: 'granulated sugar');
      final apart = _F.item('b').copyWith(combinesByFood: false);
      await repository.saveItem(sugar);
      await repository.saveItem(apart);

      await actions.separate([sugar, apart]);

      expect(repository.items[sugar.id]!.combinesByFood, isFalse);
      expect(repository.items[apart.id], apart);

      await actions.restore([sugar]);

      expect(repository.items[sugar.id], sugar);
    });
  });
}
