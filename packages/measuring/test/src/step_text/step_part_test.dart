import 'package:domain/domain.dart';
import 'package:measuring/measuring.dart';
import 'package:test/test.dart';

void main() {
  group('StepWords', () {
    test('compares by text', () {
      expect(const StepWords('Add'), const StepWords('Add'));
      expect(const StepWords('Add').hashCode, const StepWords('Add').hashCode);
      expect(const StepWords('Add'), isNot(const StepWords('Mix')));
      expect(const StepWords('Add').toString(), 'Add');
    });
  });

  group('StepMention', () {
    StepMention mention({
      Quantity? amountMax,
      String name = 'garlic',
      String? countWord,
    }) => StepMention(
      lineId: const IngredientLineId('a'),
      original: 'the garlic',
      amount: Amount(Quantity(2), null),
      amountMax: amountMax,
      name: name,
      countWord: countWord,
    );

    test('compares by value', () {
      expect(mention(), mention());
      expect(mention().hashCode, mention().hashCode);
      expect(mention(), isNot(mention(name: 'onion')));
      expect(mention(), isNot(mention(amountMax: Quantity(3))));
      expect(mention(), isNot(mention(countWord: 'clove')));
    });

    test('has a debug form', () {
      expect(mention().toString(), '[2: garlic]');
      expect(mention(amountMax: Quantity(3)).toString(), '[2-3: garlic]');
      expect(mention(countWord: 'clove').toString(), '[2 clove: garlic]');
      expect(
        StepMention(
          lineId: const IngredientLineId('a'),
          original: 'the flour',
          amount: Amount(Quantity(3, 2), .cup),
          name: 'flour',
        ).toString(),
        '[3/2 cup: flour]',
      );
    });
  });
}
