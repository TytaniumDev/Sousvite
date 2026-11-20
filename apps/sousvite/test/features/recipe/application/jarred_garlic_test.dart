import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/recipe/application/jarred_garlic.dart';

void main() {
  group('isGarlicCloves', () {
    test('finds cloves as a count word or in the name', () {
      expect(
        isGarlicCloves(name: 'garlic', unit: null, countWord: 'clove'),
        isTrue,
      );
      expect(
        isGarlicCloves(name: 'garlic cloves', unit: null, countWord: null),
        isTrue,
      );
      expect(
        isGarlicCloves(name: 'Garlic Clove', unit: null, countWord: null),
        isTrue,
      );
      expect(
        isGarlicCloves(name: 'large garlic', unit: null, countWord: 'clove'),
        isTrue,
      );
    });

    test('leaves other garlic and other cloves alone', () {
      expect(
        isGarlicCloves(
          name: 'minced garlic',
          unit: Unit.teaspoon,
          countWord: null,
        ),
        isFalse,
      );
      expect(
        isGarlicCloves(name: 'garlic', unit: null, countWord: 'head'),
        isFalse,
      );
      expect(
        isGarlicCloves(name: 'garlic', unit: null, countWord: null),
        isFalse,
      );
      expect(
        isGarlicCloves(name: 'whole cloves', unit: null, countWord: null),
        isFalse,
      );
      expect(
        isGarlicCloves(name: 'garlicky cloves', unit: null, countWord: null),
        isFalse,
      );
    });
  });

  test('shows cloves as ½ tsp of jarred garlic each', () {
    expect(
      Amount(Quantity(3), null).asJarredGarlic,
      Amount(Quantity(3, 2), Unit.teaspoon),
    );
  });
}
