import 'package:domain/domain.dart';
import 'package:measuring/measuring.dart';
import 'package:test/test.dart';

Amount _cup(int numerator, [int denominator = 1]) =>
    Amount(Quantity(numerator, denominator), .cup);
Amount _tbsp(int numerator, [int denominator = 1]) =>
    Amount(Quantity(numerator, denominator), .tablespoon);
Amount _tsp(int numerator, [int denominator = 1]) =>
    Amount(Quantity(numerator, denominator), .teaspoon);

/// The set most kitchens have: four cups and four spoons.
final List<Amount> _standard = [
  _cup(1),
  _cup(1, 2),
  _cup(1, 3),
  _cup(1, 4),
  _tbsp(1),
  _tsp(1),
  _tsp(1, 2),
  _tsp(1, 4),
];

/// The app's default set (settings), which adds ¾ and ⅔ cup and ½ Tbsp.
final List<Amount> _full = [
  _cup(1),
  _cup(3, 4),
  _cup(2, 3),
  _cup(1, 2),
  _cup(1, 3),
  _cup(1, 4),
  _tbsp(1),
  _tbsp(1, 2),
  _tsp(1),
  _tsp(1, 2),
  _tsp(1, 4),
];

/// [plan] written as "1 × 1/2 cup + 1 × 1/4 cup", for readable failures.
String? _text(List<ToolUse>? plan) => plan?.join(' + ');

void main() {
  group('decompose', () {
    group('with the standard set', () {
      final cases = {
        _cup(3, 4): '1 × 1/2 cup + 1 × 1/4 cup',
        _tsp(5): '1 × 1 tablespoon + 2 × 1 teaspoon',
        _cup(1): '1 × 1 cup',
        _cup(2): '2 × 1 cup',
        _cup(2, 3): '2 × 1/3 cup',
        _cup(3, 2): '1 × 1 cup + 1 × 1/2 cup',
        _cup(7, 4): '1 × 1 cup + 1 × 1/2 cup + 1 × 1/4 cup',
        _tbsp(2): '2 × 1 tablespoon',
        _tsp(3, 4): '1 × 1/2 teaspoon + 1 × 1/4 teaspoon',
        _tsp(3): '1 × 1 tablespoon',
        Amount(Quantity(2), .pint): '4 × 1 cup',
      };
      for (final MapEntry(key: amount, value: expected) in cases.entries) {
        test('$amount', () {
          expect(_text(decompose(amount, tools: _standard)), expected);
        });
      }
    });

    group('with the full set', () {
      final cases = {
        _cup(3, 4): '1 × 3/4 cup',
        _cup(2, 3): '1 × 2/3 cup',
        _tbsp(3, 2): '1 × 1 tablespoon + 1 × 1/2 tablespoon',
        // Ties on fills and closeness go to fewer different tools: not
        // 1 Tbsp + ½ Tbsp + ½ tsp.
        _tsp(5): '1 × 1 tablespoon + 2 × 1 teaspoon',
        _cup(5, 4): '1 × 1 cup + 1 × 1/4 cup',
      };
      for (final MapEntry(key: amount, value: expected) in cases.entries) {
        test('$amount', () {
          expect(_text(decompose(amount, tools: _full)), expected);
        });
      }
    });

    test('uses only the tools given', () {
      final plan = decompose(_cup(1), tools: [_cup(1, 3)]);

      expect(plan, [ToolUse(_cup(1, 3), 3)]);
    });

    group('within the tolerance', () {
      test('accepts a total a little off', () {
        // 1 cup + ⅛ tsp is 0.3% over a cup.
        final amount = Amount(Quantity(385, 8), .teaspoon);

        expect(_text(decompose(amount, tools: _standard)), '1 × 1 cup');
      });

      test('prefers the closest total among the fewest fills', () {
        // ⅔ cup + 1 tsp: one ⅔ cup is 3% short, and ¾ cup is 9% over.
        final amount = Amount(Quantity(33), .teaspoon);

        expect(_text(decompose(amount, tools: _full)), '1 × 2/3 cup');
      });

      test('adds a tool when the closest single tool is too far off', () {
        // 1 cup + 1 Tbsp: 1 cup alone is 6% short.
        final amount = Amount(Quantity(51), .teaspoon);

        expect(
          _text(decompose(amount, tools: _standard)),
          '1 × 1 cup + 1 × 1 tablespoon',
        );
      });

      test('follows a custom tolerance', () {
        final amount = Amount(Quantity(51), .teaspoon);

        expect(
          _text(decompose(amount, tools: _standard, tolerance: 0.1)),
          '1 × 1 cup',
        );
      });
    });

    test('converts metric volumes to the US tools', () {
      final plan = decompose(
        Amount(Quantity(240), .milliliter),
        tools: _standard,
      );

      expect(_text(plan), '1 × 1 cup');
    });

    test('lists tools largest first whatever order they are given in', () {
      final plan = decompose(_cup(7, 4), tools: _standard.reversed);

      expect(_text(plan), '1 × 1 cup + 1 × 1/2 cup + 1 × 1/4 cup');
    });

    group('returns null', () {
      final cases = {
        'for a mass': Amount(Quantity(100), .gram),
        'for a count': Amount(Quantity(2), .piece),
        'without a unit': Amount(Quantity(2), null),
        'for zero': _cup(0),
        'for a negative amount': _cup(-1),
        'when the smallest tool is too big': _tsp(1, 8),
        'for an amount too large to search': Amount(Quantity(100), .gallon),
      };
      for (final MapEntry(key: name, value: amount) in cases.entries) {
        test(name, () {
          expect(decompose(amount, tools: _standard), isNull);
        });
      }

      test('without tools', () {
        expect(decompose(_cup(1), tools: const []), isNull);
      });

      test('when no tool is a cup or spoon', () {
        final tools = [
          Amount(Quantity(1), .gram),
          Amount(Quantity(5), .milliliter),
          _cup(0),
        ];

        expect(decompose(_cup(1), tools: tools), isNull);
      });
    });
  });
}
