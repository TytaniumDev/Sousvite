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
      expect(entry.amounts, [
        (
          quantity: Quantity(3),
          unit: null,
          countWord: null,
          approximate: false,
        ),
      ]);
    });

    test('converts exactly within a unit family', () {
      final view = combineGroceryItems([
        _F.item('a', name: 'milk', quantity: Quantity(1), unit: Unit.cup),
        _F.item('b', name: 'milk', quantity: Quantity(2), unit: .tablespoon),
        _F.item('c', name: 'milk', quantity: Quantity(1, 2), unit: Unit.cup),
      ]);

      expect(view.entries['milk']!.amounts, [
        (
          quantity: Quantity(13, 8),
          unit: Unit.cup,
          countWord: null,
          approximate: false,
        ),
      ]);
    });

    test('keeps units that do not convert apart, in order, in the largest '
        'unit of each family', () {
      final view = combineGroceryItems([
        _F.item('a', name: 'flour', quantity: Quantity(1), unit: Unit.cup),
        _F.item('b', name: 'flour', quantity: Quantity(200), unit: .gram),
        _F.item('c', name: 'flour', quantity: Quantity(2)),
        _F.item('d', name: 'flour', quantity: Quantity(1), unit: .kilogram),
      ]);

      // The bare 2 has no weight, so nothing can be put together by weight.
      expect(view.entries['flour']!.amounts, [
        (
          quantity: Quantity(1),
          unit: Unit.cup,
          countWord: null,
          approximate: false,
        ),
        (
          quantity: Quantity(6, 5),
          unit: Unit.kilogram,
          countWord: null,
          approximate: false,
        ),
        (
          quantity: Quantity(2),
          unit: null,
          countWord: null,
          approximate: false,
        ),
      ]);
    });

    group('by weight', () {
      NutritionMatch match(String lineId, String food, double grams) =>
          NutritionMatch(
            id: NutritionMatchId(lineId),
            ingredientLineId: IngredientLineId(lineId),
            foodId: FoodId(food),
            source: NutritionSource.usda,
            gramWeight: grams,
          );
      const soup = RecipeId('soup');
      const cake = RecipeId('cake');

      test('puts cups and grams together in the heavier unit', () {
        final view = combineGroceryItems([
          _F.item('a', name: 'sugar', quantity: Quantity(1, 4), unit: .cup),
          _F.item('b', name: 'sugar', quantity: Quantity(2), unit: .tablespoon),
          _F.item('c', name: 'sugar', quantity: Quantity(200), unit: .gram),
        ]);

        // About 75 g of sugar in cups (by its density) and 200 g make
        // about 1 ⅓ cups.
        expect(view.entries['sugar']!.amounts, [
          (
            quantity: Quantity(4, 3),
            unit: Unit.cup,
            countWord: null,
            approximate: true,
          ),
        ]);
      });

      test('weighs lines by their nutrition match', () {
        final view = combineGroceryItems(
          [
            _F.item(
              'a',
              name: 'kale',
              quantity: Quantity(2),
              unit: .cup,
              recipeId: soup,
            ),
            _F.item('b', name: 'kale', quantity: Quantity(1), unit: .pound),
          ],
          matches: {
            const IngredientLineId('soup-a'): match('soup-a', 'kale', 134),
          },
        );

        // A pound (454 g) outweighs a cup (67 g), so the total is in
        // pounds: 588 g.
        expect(view.entries['kale']!.amounts, [
          (
            quantity: Quantity(5, 4),
            unit: Unit.pound,
            countWord: null,
            approximate: true,
          ),
        ]);
      });

      test('keeps amounts apart when one has no weight', () {
        final view = combineGroceryItems([
          _F.item('a', name: 'kale', quantity: Quantity(2), unit: .cup),
          _F.item('b', name: 'kale', quantity: Quantity(1), unit: .pound),
        ]);

        expect(view.entries['kale']!.amounts.map((a) => a.approximate), [
          false,
          false,
        ]);
      });

      test(
        'combines lines matched to the same food, under the shortest name',
        () {
          final view = combineGroceryItems(
            [
              _F.item(
                'a',
                name: 'granulated sugar',
                quantity: Quantity(200),
                unit: .gram,
                recipeId: cake,
              ),
              _F.item('b', name: 'flour', recipeId: cake),
              _F.item(
                'c',
                name: 'sugar',
                quantity: Quantity(100),
                unit: .gram,
                recipeId: soup,
              ),
              _F.item('d', name: 'Sugar', quantity: Quantity(50), unit: .gram),
            ],
            matches: {
              const IngredientLineId('cake-a'): match('cake-a', 'sugar', 200),
              const IngredientLineId('soup-c'): match('soup-c', 'sugar', 100),
            },
          );

          expect(view.entries.keys, ['granulated sugar', 'flour']);
          final sugar = view.entries['granulated sugar']!;
          expect(sugar.name, 'sugar');
          expect(sugar.items.map((item) => item.id.value), ['a', 'c', 'd']);
          expect(sugar.amounts, [
            (
              quantity: Quantity(350),
              unit: Unit.gram,
              countWord: null,
              approximate: false,
            ),
          ]);
          expect(
            view.entryFor('white sugar', foodId: const FoodId('sugar')),
            sugar,
          );
          expect(view.entryFor('Granulated Sugars'), sugar);
          expect(view.entryFor('SUGAR'), sugar);
          expect(view.entryFor('flour')?.name, 'flour');
          expect(view.entryFor('salt', foodId: const FoodId('salt')), isNull);
        },
      );
    });

    test('adds count words only with the same word', () {
      final view = combineGroceryItems([
        _F.item('a', name: 'garlic', quantity: Quantity(3), countWord: 'clove'),
        _F.item('b', name: 'garlic', quantity: Quantity(1), countWord: 'head'),
        _F.item('c', name: 'garlic', quantity: Quantity(2), countWord: 'clove'),
        _F.item('d', name: 'garlic', quantity: Quantity(1)),
      ]);

      expect(view.entries['garlic']!.amounts, [
        (
          quantity: Quantity(5),
          unit: null,
          countWord: 'clove',
          approximate: false,
        ),
        (
          quantity: Quantity(1),
          unit: null,
          countWord: 'head',
          approximate: false,
        ),
        (
          quantity: Quantity(1),
          unit: null,
          countWord: null,
          approximate: false,
        ),
      ]);
    });

    test('skips items without an amount when adding', () {
      final view = combineGroceryItems([
        _F.item('a', name: 'salt'),
        _F.item('b', name: 'Salt', quantity: Quantity(1), unit: .teaspoon),
      ]);

      expect(view.entries['salt']!.amounts, [
        (
          quantity: Quantity(1),
          unit: Unit.teaspoon,
          countWord: null,
          approximate: false,
        ),
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
