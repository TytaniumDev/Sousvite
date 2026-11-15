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

    test('converts exactly within a unit family, into the first unit', () {
      expect(
        combineAmounts([
          const Amount(Quantity.one, Unit.cup),
          Amount(Quantity(1, 2), Unit.cup),
          Amount(Quantity(2), Unit.tablespoon),
        ]),
        [Amount(Quantity(13, 8), Unit.cup)],
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
