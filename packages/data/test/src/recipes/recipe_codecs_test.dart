import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:test/test.dart';

/// Encodes [value] with [codec] and decodes it again.
T? _roundTrip<T>(EntityCodec<T> codec, T value) =>
    codec.decode(codec.idOf(value), codec.encode(value));

void main() {
  final created = DateTime.utc(2026, 11, 16);

  group(RecipeCodec, () {
    final codec = RecipeCodec();

    test('round-trips every field', () {
      final recipe = Recipe(
        id: const RecipeId('r1'),
        title: 'Soup',
        servings: Quantity(3, 2),
        createdAt: created,
        updatedAt: created.add(const Duration(hours: 1)),
        photoRef: 'photo.jpg',
        prepTime: const Duration(minutes: 10),
        cookTime: const Duration(minutes: 30),
        totalTime: const Duration(minutes: 40),
        notes: 'Good cold',
        sourceUrl: 'https://example.com/soup',
        sourceName: 'Example',
      );

      expect(codec.entity, 'recipe');
      expect(_roundTrip(codec, recipe), recipe);
    });

    test('round-trips a recipe with only the required fields', () {
      final recipe = Recipe(
        id: const RecipeId('r1'),
        title: 'Soup',
        servings: Quantity(4),
        createdAt: created,
        updatedAt: created,
      );

      expect(_roundTrip(codec, recipe), recipe);
    });

    test('waits for every required field', () {
      expect(codec.decode('r1', {'title': 'Soup'}), isNull);
    });
  });

  group(IngredientSectionCodec, () {
    final codec = IngredientSectionCodec();

    test('round-trips every field and waits for required ones', () {
      const section = IngredientSection(
        id: IngredientSectionId('s1'),
        recipeId: RecipeId('r1'),
        name: 'For the sauce',
        sortKey: SortKey('a'),
      );

      expect(codec.entity, 'ingredient_section');
      expect(_roundTrip(codec, section), section);
      expect(codec.decode('s1', {'name': 'Sauce'}), isNull);
    });
  });

  group(IngredientLineCodec, () {
    final codec = IngredientLineCodec();

    test('round-trips every field', () {
      final line = IngredientLine(
        id: const IngredientLineId('l1'),
        recipeId: const RecipeId('r1'),
        rawText: '2–3 cups rolled oats, toasted',
        sortKey: const SortKey('a'),
        sectionId: const IngredientSectionId('s1'),
        quantity: Quantity(2),
        quantityMax: Quantity(3),
        unit: Unit.cup,
        name: 'rolled oats',
        preparation: 'toasted',
      );

      expect(codec.entity, 'ingredient_line');
      expect(_roundTrip(codec, line), line);
    });

    test('round-trips a line with a count word and no section', () {
      final line = IngredientLine(
        id: const IngredientLineId('l1'),
        recipeId: const RecipeId('r1'),
        rawText: '3 cloves garlic',
        sortKey: const SortKey('a'),
        quantity: Quantity(3),
        countWord: 'clove',
        name: 'garlic',
      );

      expect(_roundTrip(codec, line), line);
    });

    test('waits for every required field', () {
      expect(codec.decode('l1', {'rawText': 'salt'}), isNull);
    });
  });

  group(StepSectionCodec, () {
    final codec = StepSectionCodec();

    test('round-trips every field and waits for required ones', () {
      const section = StepSection(
        id: StepSectionId('s1'),
        recipeId: RecipeId('r1'),
        name: 'Prep',
        sortKey: SortKey('a'),
      );

      expect(codec.entity, 'step_section');
      expect(_roundTrip(codec, section), section);
      expect(codec.decode('s1', {'name': 'Prep'}), isNull);
    });
  });

  group(RecipeStepCodec, () {
    final codec = RecipeStepCodec();

    test('round-trips every field', () {
      const step = RecipeStep(
        id: RecipeStepId('t1'),
        recipeId: RecipeId('r1'),
        text: 'Boil the water.',
        sortKey: SortKey('a'),
        sectionId: StepSectionId('s1'),
      );

      expect(codec.entity, 'recipe_step');
      expect(_roundTrip(codec, step), step);
      expect(
        _roundTrip(codec, step.copyWith(sectionId: null)),
        step.copyWith(sectionId: null),
      );
    });

    test('waits for every required field', () {
      expect(codec.decode('t1', {'text': 'Boil.'}), isNull);
    });
  });
}
