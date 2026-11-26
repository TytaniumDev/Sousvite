import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group('combineAmounts', () {
    test('is empty for no amounts', () {
      expect(combineAmounts(const []), isEmpty);
    });

    test('adds amounts in the same unit', () {
      expect(
        combineAmounts([
          Amount(Quantity(2), null),
          const Amount(Quantity.one, null),
        ]),
        [Amount(Quantity(3), null)],
      );
    });

    test('converts exactly within a unit family, into the largest unit', () {
      expect(
        combineAmounts([
          const Amount(Quantity.one, Unit.cup),
          Amount(Quantity(1, 2), Unit.cup),
          Amount(Quantity(2), Unit.tablespoon),
        ]),
        [Amount(Quantity(13, 8), Unit.cup)],
      );
    });

    test('uses the largest unit even when it comes last', () {
      expect(
        combineAmounts([
          Amount(Quantity(2), Unit.tablespoon),
          Amount(Quantity(1, 4), Unit.cup),
          Amount(Quantity(500), Unit.gram),
          const Amount(Quantity.one, Unit.kilogram),
        ]),
        [
          Amount(Quantity(3, 8), Unit.cup),
          Amount(Quantity(3, 2), Unit.kilogram),
        ],
      );
    });

    test('keeps different count units apart', () {
      expect(
        combineAmounts([
          Amount(Quantity(2), Unit.pinch),
          const Amount(Quantity.one, Unit.piece),
          const Amount(Quantity.one, Unit.pinch),
        ]),
        [
          Amount(Quantity(3), Unit.pinch),
          const Amount(Quantity.one, Unit.piece),
        ],
      );
    });

    test('keeps amounts that do not convert apart, in order', () {
      expect(
        combineAmounts([
          Amount(Quantity(200), Unit.gram),
          const Amount(Quantity.one, Unit.cup),
          Amount(Quantity(2), null),
          Amount(Quantity(100), Unit.gram),
        ]),
        [
          Amount(Quantity(300), Unit.gram),
          const Amount(Quantity.one, Unit.cup),
          Amount(Quantity(2), null),
        ],
      );
    });
  });
}
