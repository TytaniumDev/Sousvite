import 'dart:io';

import 'package:domain/domain.dart';
import 'package:recipe_import/recipe_import.dart';
import 'package:test/test.dart';

String _fixture(String name) =>
    File('test/fixtures/url/$name').readAsStringSync();

void main() {
  final now = DateTime.utc(2026, 11, 16);
  late int nextId;
  String newId() => 'id${nextId++}';
  setUp(() => nextId = 0);

  RecipePage read(
    String fixture, {
    String url = 'https://www.example.com/recipes/x',
  }) => readRecipePage(
    _fixture(fixture),
    url: Uri.parse(url),
    newId: newId,
    now: now,
  );

  group('readRecipePage', () {
    test('reads JSON-LD in a @graph, with step sections', () {
      final (:snapshot, :source, :imageUrl) = read('json_ld_graph.html');
      final recipe = snapshot.recipe;

      expect(source, RecipePageSource.jsonLd);
      expect(recipe.title, 'Easy Weeknight Chili');
      expect(recipe.servings, Quantity(6));
      expect(recipe.prepTime, const Duration(minutes: 15));
      expect(recipe.cookTime, const Duration(minutes: 45));
      expect(recipe.totalTime, const Duration(hours: 1));
      expect(recipe.sourceUrl, 'https://www.example.com/recipes/x');
      expect(recipe.sourceName, 'Weeknight Kitchen');
      expect(recipe.createdAt, now);
      expect(imageUrl, 'https://example.com/chili-1x1.jpg');

      expect(snapshot.ingredientLines.map((l) => l.rawText), [
        '1 tablespoon olive oil',
        '1 large onion, diced',
        '2 cloves garlic, minced',
        '1 ½ pounds ground beef',
        '2 (15 ounce) cans kidney beans, drained',
      ]);
      expect(
        snapshot.ingredientLines.every((l) => l.recipeId == recipe.id),
        isTrue,
      );
      expect(snapshot.stepSections.map((s) => s.name), [
        'Brown the meat',
        'Simmer',
      ]);
      expect(snapshot.steps.map((s) => s.text), [
        'Heat the oil in a large pot over medium heat.',
        'Add the onion and cook until soft, about 5 minutes.',
        'Stir in the beans and simmer for 30 minutes.',
      ]);
      expect(snapshot.steps[1].sectionId, snapshot.stepSections[0].id);
      expect(snapshot.steps[2].sectionId, snapshot.stepSections[1].id);
      final keys = snapshot.steps.map((s) => s.sortKey.value).toList();
      expect(keys, [...keys]..sort());
    });

    test('reads a JSON-LD array, skipping broken scripts', () {
      final (:snapshot, :source, :imageUrl) = read('json_ld_array.html');

      expect(source, RecipePageSource.jsonLd);
      expect(snapshot.recipe.title, 'Banana Bread');
      expect(snapshot.recipe.servings, Quantity.one);
      expect(snapshot.recipe.totalTime, const Duration(hours: 1, minutes: 10));
      expect(snapshot.recipe.sourceName, 'example.com');
      expect(imageUrl, 'https://www.example.com/img/banana-bread.jpg');
      expect(snapshot.steps.map((s) => s.text), [
        'Heat the oven to 350°F.',
        'Mash the bananas.',
        'Bake for 1 hour.',
      ]);
      expect(snapshot.stepSections, isEmpty);
    });

    test('reads a recipe that is a page main entity', () {
      final (:snapshot, :source, :imageUrl) = read('json_ld_main_entity.html');

      expect(snapshot.recipe.title, 'Overnight Oats');
      expect(snapshot.recipe.servings, Quantity(2));
      expect(snapshot.recipe.cookTime, isNull);
      expect(imageUrl, 'https://example.com/oats.jpg');
      expect(snapshot.ingredientLines, hasLength(2));
      expect(snapshot.steps.last.text, 'Chill overnight.');
    });

    test('reads microdata, ignoring nested items', () {
      final (:snapshot, :source, :imageUrl) = read('microdata.html');

      expect(source, RecipePageSource.microdata);
      expect(snapshot.recipe.title, 'Lemon Bars');
      expect(snapshot.recipe.servings, Quantity(16));
      expect(snapshot.recipe.prepTime, const Duration(minutes: 20));
      expect(snapshot.recipe.cookTime, const Duration(minutes: 40));
      expect(imageUrl, 'https://www.example.com/photos/lemon-bars.jpg');
      expect(snapshot.ingredientLines.map((l) => l.rawText), [
        '1 cup all-purpose flour',
        '1/2 cup butter',
        '2 lemons',
      ]);
      expect(snapshot.steps.map((s) => s.text), [
        'Press the crust into the pan.',
        'Bake until golden.',
      ]);
    });

    test('falls back to headings and lists', () {
      final (:snapshot, :source, :imageUrl) = read('heuristics.html');

      expect(source, RecipePageSource.heuristics);
      expect(snapshot.recipe.title, "Grandma's Pancakes");
      expect(imageUrl, isNull);
      expect(snapshot.ingredientLines.map((l) => l.rawText), [
        '2 cups flour',
        '2 eggs',
        '1 ¾ cups milk',
      ]);
      expect(snapshot.steps, hasLength(2));
    });

    test('parses each ingredient line', () {
      final (:snapshot, source: _, imageUrl: _) = read('json_ld_graph.html');
      final lines = snapshot.ingredientLines;

      expect(lines[0].quantity, Quantity.one);
      expect(lines[0].unit, Unit.tablespoon);
      expect(lines[0].name, 'olive oil');
      expect(lines[1].name, 'large onion');
      expect(lines[1].preparation, 'diced');
      expect(lines[2].name, 'cloves garlic');
      expect(lines[3].quantity, Quantity(3, 2));
      expect(lines[4].name, 'cans kidney beans');
    });

    test('starts a section at a heading line', () {
      final (:snapshot, source: _, imageUrl: _) = read('json_ld_array.html');

      expect(snapshot.ingredientLines.map((l) => l.rawText), [
        '3 ripe bananas',
        '1/3 cup melted butter',
        '3/4 cup sugar',
        '1 tablespoon cinnamon sugar',
      ]);
      expect(snapshot.ingredientSections.map((s) => s.name), ['Topping']);
      expect(snapshot.ingredientLines[2].sectionId, isNull);
      expect(
        snapshot.ingredientLines[3].sectionId,
        snapshot.ingredientSections.single.id,
      );
    });

    test('fails with a reason when the page has no recipe', () {
      expect(
        () => read('no_recipe.html', url: 'https://example.com/soup'),
        throwsA(
          isA<RecipePageFailure>()
              .having(
                (f) => f.reason,
                'reason',
                RecipePageFailureReason.noRecipe,
              )
              .having((f) => f.url.host, 'host', 'example.com')
              .having((f) => f.toString(), 'text', contains('noRecipe')),
        ),
      );
    });
  });

  group('servingsFromYield', () {
    test('reads the first whole number', () {
      expect(servingsFromYield('Serves 4-6'), Quantity(4));
      expect(servingsFromYield('12'), Quantity(12));
      expect(servingsFromYield('a few'), isNull);
      expect(servingsFromYield('0'), isNull);
      expect(servingsFromYield(null), isNull);
    });
  });
}
