import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/grocery/application/grocery_entry.dart';
import 'package:sousvite/features/grocery/application/grocery_food_merges.dart';

import '../fakes.dart';

typedef _F = GroceryFixtures;

void main() {
  group('groceryFoodMerges', () {
    test('lists each other name once, with its items, in order', () {
      final white = _F.item('b', name: 'White sugar ');
      final granulated = _F.item('c', name: 'granulated sugar');
      final whiteAgain = _F.item('d', name: 'white sugar');
      final entry = GroceryEntry(
        key: 'sugar',
        name: 'sugar',
        items: [
          _F.item('a', name: 'sugars'),
          white,
          granulated,
          whiteAgain,
        ],
        amounts: const [],
        sourceRecipeIds: const [],
      );

      final merges = groceryFoodMerges(entry);

      expect(merges.map((merge) => merge.name), [
        'White sugar',
        'granulated sugar',
      ]);
      expect(merges.first.items, [white, whiteAgain]);
      expect(merges.last.items, [granulated]);
    });
  });
}
