import 'package:domain/domain.dart';
import 'package:nutrition/nutrition.dart';
import 'package:test/test.dart';

List<FoodNutrient> _per100g(String food, Map<String, double> values) => [
  for (final MapEntry(:key, :value) in values.entries)
    FoodNutrient(foodId: FoodId(food), nutrientCode: key, amountPer100g: value),
];

void main() {
  group('batchTotals', () {
    test('scales each food by its weight and adds them up', () {
      // 200 g oats (389 kcal, 16.9 g protein per 100 g) and 244 g milk
      // (61 kcal, 3.2 g protein).
      final totals = batchTotals([
        (grams: 200, nutrients: _per100g('oats', {'208': 389, '203': 16.9})),
        (grams: 244, nutrients: _per100g('milk', {'208': 61, '203': 3.2})),
      ]);

      expect(totals['208'], closeTo(926.84, 1e-9));
      expect(totals['203'], closeTo(41.608, 1e-9));
    });

    test('is empty with no foods', () {
      expect(batchTotals(const []), isEmpty);
    });
  });

  group('perServing', () {
    test('divides the batch into servings', () {
      expect(perServing({'208': 900.0}, Quantity(4)), {'208': 225.0});
      expect(perServing({'208': 900.0}, Quantity(3, 2)), {'208': 600.0});
    });

    test('leaves the batch alone for no servings', () {
      expect(perServing({'208': 900.0}, Quantity.zero), {'208': 900.0});
    });
  });
}
