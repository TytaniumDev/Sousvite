import 'package:domain/domain.dart';
import 'package:nutrition/nutrition.dart';
import 'package:test/test.dart';

FoodPortion _portion(Unit? unit, double grams, {Quantity? amount}) =>
    FoodPortion(
      id: FoodPortionId('${unit?.name}'),
      foodId: const FoodId('f'),
      amount: amount ?? Quantity.one,
      unit: unit,
      gramWeight: grams,
    );

void main() {
  group('gramWeight', () {
    test('converts a weight directly', () {
      expect(gramWeight(Amount(Quantity(250), Unit.gram)), 250);
      expect(gramWeight(Amount(Quantity(1, 2), Unit.kilogram)), 500);
      expect(
        gramWeight(Amount(Quantity(2), Unit.pound)),
        closeTo(907.18, 0.01),
      );
    });

    test('uses a portion in the same volume unit first', () {
      // 1 ½ cups of milk at USDA's 244 g a cup.
      expect(
        gramWeight(
          Amount(Quantity(3, 2), Unit.cup),
          portions: [_portion(Unit.tablespoon, 15.3), _portion(Unit.cup, 244)],
        ),
        366,
      );
    });

    test('converts to another volume portion', () {
      // 3 tsp is 1 Tbsp; a portion of 2 Tbsp weighs 32 g.
      expect(
        gramWeight(
          Amount(Quantity(3), Unit.teaspoon),
          portions: [_portion(Unit.tablespoon, 32, amount: Quantity(2))],
        ),
        closeTo(16, 1e-9),
      );
      // 100 ml against a 1 cup portion of 240 g crosses US and metric.
      expect(
        gramWeight(
          Amount(Quantity(100), Unit.milliliter),
          portions: [_portion(Unit.cup, 240)],
        ),
        closeTo(101.44, 0.01),
      );
    });

    test('falls back to the density for a volume', () {
      // 1 cup of flour is 236.6 ml at 0.53 g/ml.
      expect(
        gramWeight(const Amount(Quantity.one, Unit.cup), density: 0.53),
        closeTo(125.4, 0.1),
      );
      expect(
        gramWeight(
          Amount(Quantity(2), Unit.tablespoon),
          portions: [_portion(null, 50), _portion(Unit.gram, 1)],
          density: 1,
        ),
        closeTo(29.57, 0.01),
      );
    });

    test('weighs a count by a portion with no unit, or the same unit', () {
      // Two large eggs at 50 g each.
      expect(
        gramWeight(Amount(Quantity(2), null), portions: [_portion(null, 50)]),
        100,
      );
      expect(
        gramWeight(
          Amount(Quantity(3), Unit.piece),
          portions: [_portion(null, 50), _portion(Unit.piece, 20)],
        ),
        60,
      );
    });

    test('is null when it can not be worked out', () {
      expect(gramWeight(const Amount(Quantity.one, Unit.cup)), isNull);
      expect(gramWeight(Amount(Quantity(2), null)), isNull);
      expect(
        gramWeight(
          Amount(Quantity(2), null),
          portions: [_portion(null, 50, amount: Quantity.zero)],
        ),
        isNull,
      );
    });
  });
}
