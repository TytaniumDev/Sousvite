import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/nutrition/application/nutrient.dart';
import 'package:sousvite/features/nutrition/application/nutrition_math.dart';

import '../fakes.dart';

typedef _F = NutritionFixtures;

void main() {
  group('batchTotals', () {
    test('scales per-100 g values by each line weight and adds them', () {
      const oats = FoodId('oats');
      const milk = FoodId('milk');
      final totals = batchTotals(
        [_F.match('l1', 'oats', 80), _F.match('l2', 'milk', 250)],
        {
          oats: const [
            FoodNutrient(foodId: oats, nutrientCode: '208', amountPer100g: 380),
            FoodNutrient(foodId: oats, nutrientCode: '203', amountPer100g: 13),
            // Not a nutrient the app shows.
            FoodNutrient(foodId: oats, nutrientCode: '999', amountPer100g: 1),
          ],
          milk: const [
            FoodNutrient(foodId: milk, nutrientCode: '208', amountPer100g: 60),
          ],
        },
      );

      expect(totals, {Nutrient.calories: 304 + 150, Nutrient.protein: 10.4});
    });

    test('adds nothing for a food without nutrients', () {
      expect(batchTotals([_F.match('l1', 'x', 100)], const {}), isEmpty);
    });
  });

  group('perServing', () {
    test('divides the batch', () {
      expect(perServing({Nutrient.calories: 600}, Quantity(4)), {
        Nutrient.calories: 150,
      });
    });

    test('keeps the batch for zero servings', () {
      expect(perServing({Nutrient.fat: 10}, Quantity.zero), {Nutrient.fat: 10});
    });
  });

  group('estimateGrams', () {
    final cup = FoodPortion(
      id: const FoodPortionId('p1'),
      foodId: const FoodId('oats'),
      amount: Quantity(1, 2),
      unit: Unit.cup,
      gramWeight: 40,
    );
    const egg = FoodPortion(
      id: FoodPortionId('p2'),
      foodId: FoodId('egg'),
      amount: Quantity.one,
      gramWeight: 50,
      description: '1 large egg',
    );

    test('converts weights directly', () {
      expect(
        estimateGrams(_F.line('l', quantity: Quantity(2), unit: .pound), []),
        closeTo(907.18, 0.01),
      );
      expect(
        estimateGrams(
          _F.line('l', quantity: Quantity(1, 2), unit: .kilogram),
          [],
        ),
        500,
      );
    });

    test('uses a portion in the same unit', () {
      expect(
        estimateGrams(_F.line('l', quantity: Quantity(1), unit: .cup), [cup]),
        80,
      );
      expect(estimateGrams(_F.line('l', quantity: Quantity(2)), [egg]), 100);
    });

    test('converts to a portion in another volume unit', () {
      // 1 tsp is 1/48 cup; half a cup weighs 40 g.
      expect(
        estimateGrams(_F.line('l', quantity: Quantity(1), unit: .teaspoon), [
          cup,
        ]),
        closeTo(5 / 3, 1e-9),
      );
    });

    test('uses the density of the food, else of the ingredient', () {
      final oneCup = _F.line('flour', quantity: Quantity(1), unit: .cup);
      expect(
        estimateGrams(oneCup, const [], foodName: 'Sugars, granulated'),
        closeTo(201.1, 0.1),
      );
      expect(estimateGrams(oneCup, const []), closeTo(125.4, 0.1));
      expect(
        estimateGrams(oneCup, const [], foodName: 'Mystery food'),
        closeTo(125.4, 0.1),
      );
    });

    test('is null without an amount, a portion, or a density', () {
      expect(estimateGrams(_F.line('l'), [cup]), isNull);
      expect(
        estimateGrams(_F.line('l', quantity: Quantity(1), unit: .cup), [
          cup.copyWith(amount: Quantity.zero),
        ]),
        isNull,
      );
    });
  });

  test('Nutrient finds nutrients by USDA number', () {
    expect(Nutrient.fromCode('203'), Nutrient.protein);
    expect(Nutrient.fromCode('000'), isNull);
    expect(Nutrient.sugars.parent, Nutrient.carbs);
  });
}
