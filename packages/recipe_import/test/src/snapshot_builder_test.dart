import 'package:domain/domain.dart';
import 'package:recipe_import/src/snapshot_builder.dart';
import 'package:test/test.dart';

void main() {
  group('buildSnapshot', () {
    test('keeps notes, times, and sections in first-seen order', () {
      var nextId = 0;
      final snapshot = buildSnapshot(
        title: 'Soup',
        ingredients: const [
          (section: 'Broth', text: '4 cups water'),
          (section: null, text: '1 onion'),
          (section: 'Broth', text: '1 tsp salt'),
        ],
        steps: const [
          (section: 'Simmer', text: 'Boil.'),
          (section: 'Serve', text: 'Ladle.'),
          (section: 'Simmer', text: 'Stir.'),
        ],
        newId: () => 'id${nextId++}',
        now: DateTime.utc(2026),
        yield: '2 bowls',
        totalTime: const Duration(minutes: 30),
        notes: 'Freezes well.',
      );

      expect(snapshot.recipe.servings, Quantity(2));
      expect(snapshot.recipe.totalTime, const Duration(minutes: 30));
      expect(snapshot.recipe.notes, 'Freezes well.');
      expect(snapshot.recipe.sourceUrl, isNull);
      expect(snapshot.ingredientSections.map((s) => s.name), ['Broth']);
      expect(snapshot.ingredientLines[1].sectionId, isNull);
      expect(
        snapshot.ingredientLines[2].sectionId,
        snapshot.ingredientSections.single.id,
      );
      expect(snapshot.stepSections.map((s) => s.name), ['Simmer', 'Serve']);
      expect(snapshot.steps[2].sectionId, snapshot.stepSections.first.id);
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

  test('sortKeyAt keys sort in index order', () {
    expect(sortKeyAt(2).value.compareTo(sortKeyAt(10).value), isNegative);
  });
}
