import 'dart:convert';
import 'dart:io';

import 'package:domain/domain.dart';
import 'package:measuring/measuring.dart';
import 'package:test/test.dart';

var _nextId = 0;

IngredientLine _line(
  String? name, {
  Quantity? quantity,
  Quantity? quantityMax,
  Unit? unit,
}) => IngredientLine(
  id: IngredientLineId('line-${_nextId++}'),
  recipeId: const RecipeId('recipe'),
  rawText: '',
  sortKey: const SortKey('a'),
  quantity: quantity,
  quantityMax: quantityMax,
  unit: unit,
  name: name,
);

/// [parts] with each mention written as `{amount unit name}`.
String _render(List<StepPart> parts) => parts
    .map(
      (part) => switch (part) {
        StepWords(:final text) => text,
        StepMention(:final amount, :final amountMax, :final name) =>
          '{${amount.quantity}${amountMax == null ? '' : '-$amountMax'}'
              '${amount.unit == null ? '' : ' ${amount.unit!.name}'} $name}',
      },
    )
    .join();

String _smart(String step, List<IngredientLine> lines, {Quantity? scale}) =>
    _render(smartStepText(step, lines, scale: scale ?? Quantity.one));

Quantity _quantity(String text) {
  final parts = text.split('/');
  return Quantity(
    int.parse(parts.first),
    parts.length == 2 ? int.parse(parts.last) : 1,
  );
}

void main() {
  final flour = _line('all-purpose flour', quantity: Quantity(2), unit: .cup);
  final garlic = _line('garlic cloves', quantity: Quantity(3));

  group('smartStepText', () {
    test('places the amount before the name', () {
      expect(
        _smart('Whisk in flour.', [flour]),
        'Whisk in {2 cup all-purpose flour}.',
      );
    });

    test('scales the amount', () {
      expect(
        _smart('Add garlic.', [garlic], scale: Quantity(2)),
        'Add {6 garlic cloves}.',
      );
    });

    test('scales both ends of a range', () {
      final cloves = _line(
        'garlic',
        quantity: Quantity(2),
        quantityMax: Quantity(3),
      );

      expect(
        _smart('Add the garlic.', [cloves], scale: Quantity(2)),
        'Add {4-6 garlic}.',
      );
    });

    test('replaces "the" or "your" with the amount', () {
      expect(
        _smart('Add the flour.', [flour]),
        'Add {2 cup all-purpose flour}.',
      );
      expect(
        _smart('Add your flour.', [flour]),
        'Add {2 cup all-purpose flour}.',
      );
    });

    test('keeps what the mention replaced, for undo', () {
      final mention = smartStepText('Sift the flour.', [
        flour,
      ]).whereType<StepMention>().single;

      expect(mention.original, 'the flour');
      expect(mention.lineId, flour.id);
    });

    group('finds', () {
      test('the end of the name', () {
        final oats = _line(
          'old-fashioned rolled oats',
          quantity: Quantity(1),
          unit: .cup,
        );

        expect(
          _smart('Stir in oats.', [oats]),
          'Stir in {1 cup old-fashioned rolled oats}.',
        );
      });

      test('the name without its count word', () {
        expect(_smart('Mince garlic.', [garlic]), 'Mince {3 garlic cloves}.');
      });

      test('singular and plural alike', () {
        final tomatoes = _line('tomatoes', quantity: Quantity(2));
        final berries = _line('strawberry', quantity: Quantity(4));

        expect(
          _smart('Slice the tomato and the strawberries.', [tomatoes, berries]),
          'Slice {2 tomatoes} and {4 strawberry}.',
        );
      });

      test('an alternative', () {
        final butter = _line(
          'butter or ghee',
          quantity: Quantity(1),
          unit: .tablespoon,
        );

        expect(
          _smart('Melt the ghee.', [butter]),
          'Melt {1 tablespoon butter or ghee}.',
        );
      });

      test('a name split by a slash', () {
        final starch = _line(
          'cornstarch/flour',
          quantity: Quantity(1),
          unit: .tablespoon,
        );

        expect(
          _smart('Add cornstarch.', [starch]),
          'Add {1 tablespoon cornstarch/flour}.',
        );
      });

      test('a name with commas', () {
        final thighs = _line(
          'boneless, skinless chicken thighs',
          quantity: Quantity(1),
          unit: .pound,
        );

        expect(
          _smart('Add the boneless, skinless chicken thighs.', [thighs]),
          'Add {1 pound boneless, skinless chicken thighs}.',
        );
      });

      test('the longest match first', () {
        final sugar = _line('sugar', quantity: Quantity(1), unit: .cup);
        final brown = _line(
          'brown sugar',
          quantity: Quantity(1, 2),
          unit: .cup,
        );

        expect(
          _smart('Beat the brown sugar and sugar.', [sugar, brown]),
          'Beat {1/2 cup brown sugar} and {1 cup sugar}.',
        );
      });

      test('a short form only when one line has it', () {
        final black = _line(
          'black pepper',
          quantity: Quantity(1),
          unit: .teaspoon,
        );
        final bell = _line('red bell pepper', quantity: Quantity(1));

        expect(
          _smart('Add the pepper, then the bell pepper.', [black, bell]),
          'Add the pepper, then {1 red bell pepper}.',
        );
      });

      test("a line's whole name even when another line ends with it", () {
        final oil = _line('oil', quantity: Quantity(2), unit: .tablespoon);
        final olive = _line(
          'olive oil',
          quantity: Quantity(1),
          unit: .tablespoon,
        );

        expect(
          _smart('Heat the oil.', [oil, olive]),
          'Heat {2 tablespoon oil}.',
        );
      });

      test('lowercases a capitalized name inside a sentence', () {
        final onion = _line('Onion', quantity: Quantity(1));

        expect(_smart('Dice the onion.', [onion]), 'Dice {1 onion}.');
        expect(
          _smart('Onion goes in first.', [onion]),
          '{1 Onion} goes in first.',
        );
      });

      test('an all-caps name as written', () {
        final msg = _line('MSG', quantity: Quantity(1), unit: .teaspoon);

        expect(_smart('Add msg.', [msg]), 'Add {1 teaspoon MSG}.');
      });
    });

    group('leaves as written', () {
      final cases = {
        'a mention with an amount': 'Add 1 cup flour.',
        'a mention with an amount and "of"': 'Add 1 cup of the flour.',
        'a mention with a unit': 'Add a cup of flour.',
        'a part of the amount': 'Add half the flour.',
        'the rest': 'Add the remaining flour.',
        'something made from it': 'Pour in the flour mixture.',
        'a describing word alone': 'Add the red wine.',
        'a count word alone': 'Add the cloves.',
        'a cooking verb': 'Roast for an hour.',
      };
      final lines = [
        flour,
        _line('red onion', quantity: Quantity(1)),
        garlic,
        _line('chuck roast', quantity: Quantity(3), unit: .pound),
        _line('chicken broth', quantity: Quantity(4), unit: .cup),
      ];
      for (final MapEntry(key: name, value: step) in cases.entries) {
        test(name, () {
          expect(_smart(step, lines), step);
        });
      }

      test('two words across a comma or a period as one name', () {
        final broth = _line('chicken broth', quantity: Quantity(4), unit: .cup);

        for (final step in ['Add the chicken, broth.', 'Add chicken. Broth.']) {
          final mention = smartStepText(step, [
            broth,
          ]).whereType<StepMention>().single;

          expect(mention.original.toLowerCase(), 'broth', reason: step);
        }
      });

      test('a line without an amount', () {
        final salt = _line('salt');

        expect(_smart('Season with salt.', [salt]), 'Season with salt.');
      });

      test('a line without a name', () {
        expect(
          _smart('Add it.', [_line(null, quantity: Quantity(1))]),
          'Add it.',
        );
      });

      test('a later mention of the same line', () {
        expect(
          _smart('Add the flour, then sift the flour.', [flour]),
          'Add {2 cup all-purpose flour}, then sift the flour.',
        );
      });

      test('the first mention when it is partial, and the ones after it', () {
        expect(
          _smart('Add half the flour, then the flour.', [flour]),
          'Add half the flour, then the flour.',
        );
      });
    });

    test('keeps a step without mentions as one part', () {
      expect(smartStepText('Preheat the oven.', [flour]), [
        const StepWords('Preheat the oven.'),
      ]);
    });

    test('returns no parts for an empty step', () {
      expect(smartStepText('', [flour]), isEmpty);
    });
  });

  group('smartSteps', () {
    test('places each amount at its first mention in the recipe', () {
      final steps = smartSteps(
        ['Add the flour.', 'Mix the flour and garlic.'],
        [flour, garlic],
      );

      expect(steps.map(_render), [
        'Add {2 cup all-purpose flour}.',
        'Mix the flour and {3 garlic cloves}.',
      ]);
    });

    group('on real recipes', () {
      final recipes = jsonDecode(
        File('test/fixtures/step_text_recipes.json').readAsStringSync(),
      ) as List<Object?>;
      for (final recipe in recipes.cast<Map<String, Object?>>()) {
        test(recipe['title'], () {
          final lines = [
            for (final line
                in (recipe['lines']! as List).cast<Map<String, Object?>>())
              _line(
                line['name'] as String?,
                quantity: switch (line['quantity']) {
                  final String text => _quantity(text),
                  _ => null,
                },
                unit: switch (line['unit']) {
                  final String name => Unit.values.byName(name),
                  _ => null,
                },
              ),
          ];
          final steps = (recipe['steps']! as List).cast<String>();

          expect(
            smartSteps(steps, lines).map(_render).toList(),
            recipe['expected'],
          );
        });
      }
    });
  });
}
