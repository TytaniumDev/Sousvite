import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/grocery/application/combine_grocery_items.dart';

import '../fakes.dart';

typedef _F = GroceryFixtures;

void main() {
  group('combineGroceryItems', () {
    test('is empty for no items', () {
      final view = combineGroceryItems(const []);

      expect(view.isEmpty, isTrue);
      expect(view.sections, isEmpty);
      expect(view.checkedKeys, isEmpty);
    });

    test('adds amounts of the same item in the same unit', () {
      final view = combineGroceryItems([
        _F.item('a', name: 'Onion', quantity: Quantity(2)),
        _F.item('b', name: 'onion ', quantity: Quantity(1)),
      ]);

      final entry = view.entries['onion']!;
      expect(entry.name, 'Onion');
      expect(entry.items, hasLength(2));
      expect(entry.amounts, [(quantity: Quantity(3), unit: null)]);
    });

    test('keeps different units apart, in the order they appear', () {
      final view = combineGroceryItems([
        _F.item('a', name: 'milk', quantity: Quantity(1), unit: Unit.cup),
        _F.item('b', name: 'milk', quantity: Quantity(2), unit: .tablespoon),
        _F.item('c', name: 'milk', quantity: Quantity(1, 2), unit: Unit.cup),
      ]);

      expect(view.entries['milk']!.amounts, [
        (quantity: Quantity(3, 2), unit: Unit.cup),
        (quantity: Quantity(2), unit: Unit.tablespoon),
      ]);
    });

    test('skips items without an amount when adding', () {
      final view = combineGroceryItems([
        _F.item('a', name: 'salt'),
        _F.item('b', name: 'Salt', quantity: Quantity(1), unit: .teaspoon),
      ]);

      expect(view.entries['salt']!.amounts, [
        (quantity: Quantity(1), unit: Unit.teaspoon),
      ]);
      expect(
        combineGroceryItems([_F.item('a')]).entries['a']!.amounts,
        isEmpty,
      );
    });

    test('lists each source recipe once', () {
      const soup = RecipeId('soup');
      const stew = RecipeId('stew');
      final view = combineGroceryItems([
        _F.item('a', name: 'onion', recipeId: soup),
        _F.item('b', name: 'onion', recipeId: stew),
        _F.item('c', name: 'onion', recipeId: soup),
        _F.item('d', name: 'onion'),
      ]);

      expect(view.entries['onion']!.sourceRecipeIds, [soup, stew]);
    });

    test('groups unchecked entries by section, "Other" last', () {
      final view = combineGroceryItems([
        _F.item('milk'),
        _F.item('apples', storeSection: 'Produce'),
        _F.item('cheese', storeSection: 'dairy'),
        _F.item('pears', storeSection: 'Produce'),
      ]);

      expect(view.sections.map((section) => section.name), [
        'dairy',
        'Produce',
        null,
      ]);
      expect(view.sections[1].entryKeys, ['apples', 'pears']);
    });

    test('takes the first section any item has', () {
      final view = combineGroceryItems([
        _F.item('a', name: 'onion'),
        _F.item('b', name: 'onion', storeSection: 'Produce'),
      ]);

      expect(view.entries['onion']!.storeSection, 'Produce');
    });

    test('moves an entry to checked only when all its items are', () {
      final view = combineGroceryItems([
        _F.item('a', name: 'onion', checked: true),
        _F.item('b', name: 'onion'),
        _F.item('eggs', checked: true),
      ]);

      expect(view.entries['onion']!.checked, isFalse);
      expect(view.checkedKeys, ['eggs']);
      expect(view.sections.single.entryKeys, ['onion']);
    });
  });

  test('groceryKey ignores case and spacing', () {
    expect(groceryKey('  Green   Onion '), 'green onion');
  });
}
