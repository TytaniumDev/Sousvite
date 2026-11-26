import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/grocery/application/combine_grocery_items.dart';
import 'package:sousvite/features/grocery/application/grocery_sources.dart';

import '../fakes.dart';

typedef _F = GroceryFixtures;

void main() {
  group('grocerySources', () {
    test('adds up each recipe’s items, in the order recipes appear', () {
      const soup = RecipeId('soup');
      const stew = RecipeId('stew');
      final entry = combineGroceryItems([
        _F.item('a', name: 'onion', quantity: Quantity(1), recipeId: stew),
        _F.item('b', name: 'onion', quantity: Quantity(2), recipeId: soup),
        _F.item('c', name: 'onions', quantity: Quantity(1), recipeId: stew),
        _F.item('d', name: 'onion'),
      ]).entries.values.single;

      final sources = grocerySources(entry);
      expect(sources.map((source) => source.recipeId), [stew, soup, null]);
      expect(sources.map((source) => source.amounts), [
        [
          (
            quantity: Quantity(2),
            unit: null,
            countWord: null,
            approximate: false,
          ),
        ],
        [
          (
            quantity: Quantity(2),
            unit: null,
            countWord: null,
            approximate: false,
          ),
        ],
        isEmpty,
      ]);
    });
  });
}
