import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/grocery/application/grocery_amounts.dart';

import '../fakes.dart';

typedef _F = GroceryFixtures;

void main() {
  group('groceryAmounts', () {
    test('adds amounts by unit and count word, skipping items without one, '
        'in the largest unit', () {
      expect(
        groceryAmounts([
          _F.item('a', quantity: Quantity(2), unit: Unit.tablespoon),
          _F.item('b', quantity: Quantity(1, 4), unit: Unit.cup),
          _F.item('c', quantity: Quantity(3), countWord: 'clove'),
          _F.item('d', quantity: Quantity(200), unit: Unit.gram),
          _F.item('e'),
          _F.item('f', quantity: Quantity(1), countWord: 'clove'),
        ]),
        [
          (
            quantity: Quantity(3, 8),
            unit: Unit.cup,
            countWord: null,
            approximate: false,
          ),
          (
            quantity: Quantity(200),
            unit: Unit.gram,
            countWord: null,
            approximate: false,
          ),
          (
            quantity: Quantity(4),
            unit: null,
            countWord: 'clove',
            approximate: false,
          ),
        ],
      );
    });

    test('weighs only amounts without a count word', () {
      final amounts = groceryAmounts([
        _F.item('a', quantity: Quantity(2), countWord: 'clove'),
        _F.item('b', quantity: Quantity(1), unit: Unit.tablespoon),
        _F.item('c', quantity: Quantity(1), countWord: 'head'),
      ], gramsOf: (_) => 10);

      expect(
        amounts.map((amount) => amount.approximate),
        everyElement(isFalse),
      );
      expect(amounts, hasLength(3));
    });
  });
}
