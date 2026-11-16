import 'dart:io';

import 'package:domain/domain.dart';
import 'package:recipe_import/recipe_import.dart';
import 'package:recipe_import/src/umami/umami_html.dart';
import 'package:test/test.dart';

String _fixture(String name) =>
    File('test/fixtures/umami/$name').readAsStringSync();

void main() {
  final now = DateTime.utc(2026, 11, 16);
  late int nextId;
  String newId() => 'id${nextId++}';
  setUp(() => nextId = 0);

  UmamiRecipe read(String page) => readUmamiHtml(page, newId: newId, now: now)!;

  String sectionOf(RecipeSnapshot snapshot, IngredientLine line) => snapshot
      .ingredientSections
      .firstWhere((s) => s.id == line.sectionId)
      .name;

  group('readUmamiHtml', () {
    test('reads the details, photo, and notes', () {
      final (:snapshot, :book, :imageUrl) = read(
        _fixture('skillet_chicken.html'),
      );
      final recipe = snapshot.recipe;

      expect(recipe.title, 'Lemon Skillet Chicken & Rice');
      expect(book, 'Weeknight');
      expect(recipe.servings, Quantity(4));
      expect(recipe.totalTime, const Duration(hours: 1, minutes: 5));
      expect(recipe.prepTime, const Duration(minutes: 20));
      expect(recipe.cookTime, isNull);
      expect(recipe.createdAt, now);
      expect(
        imageUrl,
        'https://www.umami.recipes/api/image/recipes/abc/images/def?w=1080&q=75',
      );
      expect(recipe.notes, 'Thighs stay juicier than breasts.\nKeeps 3 days.');
    });

    test('turns bold items into ingredient sections', () {
      final (:snapshot, book: _, imageUrl: _) = read(
        _fixture('skillet_chicken.html'),
      );
      final lines = snapshot.ingredientLines;

      expect(lines.map((l) => l.rawText), [
        '1 tablespoon olive oil',
        '4 chicken thighs',
        '2 cloves garlic, minced',
        '1 cup long-grain rice',
        '2 cups chicken broth',
      ]);
      expect(snapshot.ingredientSections.map((s) => s.name), [
        'Chicken',
        'Rice',
      ]);
      expect(lines.first.sectionId, isNull);
      expect(sectionOf(snapshot, lines[2]), 'Chicken');
      expect(sectionOf(snapshot, lines[3]), 'Rice');
      expect(lines[2].countWord, 'clove');
    });

    test('reads steps without their typed numbers, in sections', () {
      final (:snapshot, book: _, imageUrl: _) = read(
        _fixture('skillet_chicken.html'),
      );

      expect(snapshot.steps.map((s) => s.text), [
        'Heat the oil in a skillet.',
        'Brown the chicken, 5 minutes a side.',
        'Rice: stir in the rice and broth, then bake for 40 minutes.',
      ]);
      expect(snapshot.stepSections.single.name, 'Finish');
      expect(snapshot.steps[1].sectionId, isNull);
      expect(snapshot.steps[2].sectionId, snapshot.stepSections.single.id);
    });

    test('reads a recipe with only a name and a book', () {
      final (:snapshot, :book, :imageUrl) = read(_fixture('plain_toast.html'));

      expect(snapshot.recipe.title, 'Plain Toast');
      expect(book, 'Breakfast');
      expect(snapshot.recipe.servings, Quantity.one);
      expect(snapshot.recipe.totalTime, isNull);
      expect(snapshot.recipe.notes, isEmpty);
      expect(imageUrl, isNull);
      expect(snapshot.ingredientLines, isEmpty);
      expect(snapshot.steps, isEmpty);
    });

    test('is null for a page without a recipe name', () {
      expect(readUmamiHtml('<p>Hello</p>', newId: newId, now: now), isNull);
    });
  });

  group('writeUmamiHtml', () {
    test('writes a page that reads back the same', () {
      final original = read(_fixture('skillet_chicken.html'));

      final again = read(writeUmamiHtml(original));

      expect(again.book, original.book);
      expect(again.imageUrl, original.imageUrl);
      expect(again.snapshot.recipe.title, original.snapshot.recipe.title);
      expect(again.snapshot.recipe.servings, original.snapshot.recipe.servings);
      expect(again.snapshot.recipe.prepTime, original.snapshot.recipe.prepTime);
      expect(
        again.snapshot.recipe.totalTime,
        original.snapshot.recipe.totalTime,
      );
      expect(again.snapshot.recipe.notes, original.snapshot.recipe.notes);
      for (final snapshot in [original.snapshot, again.snapshot]) {
        expect(snapshot.ingredientLines.map((l) => l.rawText), hasLength(5));
      }
      expect(
        again.snapshot.ingredientLines.map(
          (l) => (l.rawText, l.sectionId == null),
        ),
        original.snapshot.ingredientLines.map(
          (l) => (l.rawText, l.sectionId == null),
        ),
      );
      expect(
        again.snapshot.ingredientSections.map((s) => s.name),
        original.snapshot.ingredientSections.map((s) => s.name),
      );
      expect(
        again.snapshot.steps.map((s) => s.text),
        original.snapshot.steps.map((s) => s.text),
      );
      expect(
        again.snapshot.stepSections.map((s) => s.name),
        original.snapshot.stepSections.map((s) => s.name),
      );
    });

    test('escapes text, says one serving, and leaves out what is unset', () {
      final recipe = Recipe(
        id: const RecipeId('r'),
        title: 'Salt <& pepper>',
        servings: Quantity.one,
        createdAt: now,
        updatedAt: now,
        cookTime: const Duration(minutes: 5),
      );
      final page = writeUmamiHtml((
        snapshot: RecipeSnapshot(
          recipe: recipe,
          ingredientLines: [
            IngredientLine(
              id: const IngredientLineId('l'),
              recipeId: recipe.id,
              rawText: 'a pinch',
              sortKey: const SortKey('a'),
              // A section that no longer exists counts as none.
              sectionId: const IngredientSectionId('gone'),
            ),
          ],
        ),
        book: null,
        imageUrl: null,
      ));

      expect(page, contains('<h1>Salt &lt;&amp; pepper&gt;</h1>'));
      expect(page, contains('<strong>1 serving</strong>'));
      expect(page, isNot(contains('Recipe Book')));
      expect(page, isNot(contains('Time')));
      expect(page, isNot(contains('<img')));
      expect(page, contains('<ul><li><p><span>a pinch</span></p></li></ul>'));
    });
  });
}
