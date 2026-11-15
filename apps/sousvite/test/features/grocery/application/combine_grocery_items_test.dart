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

    test('converts exactly within a unit family', () {
      final view = combineGroceryItems([
        _F.item('a', name: 'milk', quantity: Quantity(1), unit: Unit.cup),
        _F.item('b', name: 'milk', quantity: Quantity(2), unit: .tablespoon),
        _F.item('c', name: 'milk', quantity: Quantity(1, 2), unit: Unit.cup),
      ]);

      expect(view.entries['milk']!.amounts, [
        (quantity: Quantity(13, 8), unit: Unit.cup),
      ]);
    });

    test('keeps units that do not convert apart, in order', () {
      final view = combineGroceryItems([
        _F.item('a', name: 'flour', quantity: Quantity(1), unit: Unit.cup),
        _F.item('b', name: 'flour', quantity: Quantity(200), unit: .gram),
        _F.item('c', name: 'flour', quantity: Quantity(2)),
        _F.item('d', name: 'flour', quantity: Quantity(1), unit: .kilogram),
      ]);

      expect(view.entries['flour']!.amounts, [
        (quantity: Quantity(1), unit: Unit.cup),
        (quantity: Quantity(1200), unit: Unit.gram),
        (quantity: Quantity(2), unit: null),
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

    test('groups by section in store order, then named ones, "Other" last', () {
      final view = combineGroceryItems([
        _F.item('paper towels'),
        _F.item('chips', storeSection: 'Snacks'),
        _F.item('cheese', storeSection: 'dairyAndEggs'),
        _F.item('apples'),
        _F.item('pears', storeSection: 'produce'),
        _F.item('candles', storeSection: 'Home'),
      ]);

      expect(view.sections.map((section) => section.name), [
        'produce',
        'dairyAndEggs',
        'Home',
        'Snacks',
        null,
      ]);
      expect(view.sections.first.entryKeys, ['apple', 'pear']);
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
      expect(view.checkedKeys, ['egg']);
      expect(view.sections.single.entryKeys, ['onion']);
    });
  });
}
