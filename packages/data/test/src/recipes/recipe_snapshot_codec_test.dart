import 'dart:convert';

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group(RecipeSnapshotCodec, () {
    const codec = RecipeSnapshotCodec();
    const recipeId = RecipeId('r1');
    final snapshot = RecipeSnapshot(
      recipe: Recipe(
        id: recipeId,
        title: 'Oatmeal',
        servings: Quantity(2),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
      ingredientSections: [
        const IngredientSection(
          id: IngredientSectionId('is1'),
          recipeId: recipeId,
          name: 'Base',
          sortKey: SortKey('a'),
        ),
      ],
      ingredientLines: [
        IngredientLine(
          id: const IngredientLineId('l1'),
          recipeId: recipeId,
          rawText: '1 cup oats',
          sortKey: const SortKey('a'),
          sectionId: const IngredientSectionId('is1'),
          quantity: Quantity(1),
          unit: Unit.cup,
        ),
        const IngredientLine(
          id: IngredientLineId('l2'),
          recipeId: recipeId,
          rawText: 'Salt',
          sortKey: SortKey('b'),
        ),
      ],
      stepSections: [
        const StepSection(
          id: StepSectionId('ss1'),
          recipeId: recipeId,
          name: 'Prep',
          sortKey: SortKey('a'),
        ),
      ],
      steps: [
        const RecipeStep(
          id: RecipeStepId('s1'),
          recipeId: recipeId,
          text: 'Boil water.',
          sortKey: SortKey('a'),
        ),
      ],
    );

    test('round-trips a whole recipe through JSON', () {
      final json = jsonDecode(jsonEncode(codec.encode(snapshot)));

      expect(codec.decode(json as List<Object?>), snapshot);
    });

    test('encodes one record per entity, the recipe first', () {
      final records = codec.encode(snapshot);

      expect(records.map((r) => r['entity']), [
        'recipe',
        'ingredient_section',
        'ingredient_line',
        'ingredient_line',
        'step_section',
        'recipe_step',
      ]);
      expect(records.first['entityId'], 'r1');
    });

    test('puts parts in sort order', () {
      final records = codec.encode(snapshot);
      final lines = records.where((r) => r['entity'] == 'ingredient_line');

      final decoded = codec.decode([records.first, ...lines.toList().reversed]);

      expect(decoded?.ingredientLines.map((l) => l.rawText), [
        '1 cup oats',
        'Salt',
      ]);
    });

    test('is null without a valid recipe', () {
      expect(codec.decode([]), isNull);
      expect(
        codec.decode([
          {'entity': 'recipe', 'entityId': 'r1', 'fields': <String, Object?>{}},
        ]),
        isNull,
      );
    });

    test('skips malformed records and parts of other recipes', () {
      final records = codec.encode(snapshot);

      final decoded = codec.decode([
        ...records,
        'nonsense',
        {'entity': 'recipe_step'},
        {
          'entity': 'recipe_step',
          'entityId': 'other',
          'fields': {'recipeId': 'r2', 'text': 'x', 'sortKey': 'a'},
        },
      ]);

      expect(decoded, snapshot);
    });
  });
}
