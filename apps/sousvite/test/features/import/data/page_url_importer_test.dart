import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/import/application/import_failure.dart';
import 'package:sousvite/features/import/data/page_url_importer.dart';

const _recipePage = r'''
<html><head><script type="application/ld+json">
{"@type": "Recipe", "name": "Toast", "recipeYield": "2",
 "recipeIngredient": ["2 slices bread", "1 tbsp butter"],
 "recipeInstructions": "Toast the bread.\nButter it."}
</script></head></html>''';

void main() {
  group('PageUrlImporter', () {
    test('reads the fetched page as an unsaved recipe', () async {
      final requested = <Uri>[];
      var nextId = 0;
      final importer = PageUrlImporter((url) async {
        requested.add(url);
        return (url: Uri.parse('https://b.com/toast'), html: _recipePage);
      }, newId: () => 'id${nextId++}');

      final snapshot = await withClock(
        Clock.fixed(DateTime.utc(2026, 11, 16)),
        () => importer.importUrl(Uri.parse('https://a.com/t')),
      );

      expect(requested, [Uri.parse('https://a.com/t')]);
      expect(snapshot.recipe.title, 'Toast');
      expect(snapshot.recipe.createdAt, DateTime.utc(2026, 11, 16));
      // The address after redirects is the recipe's source.
      expect(snapshot.recipe.sourceUrl, 'https://b.com/toast');
      expect(snapshot.ingredientLines.last.name, 'butter');
      expect(snapshot.steps, hasLength(2));
    });

    test('fails with noRecipe when the page has none', () async {
      final importer = PageUrlImporter(
        (url) async => (url: url, html: '<p>Hello</p>'),
        newId: () => 'id',
      );

      await expectLater(
        importer.importUrl(Uri.parse('https://a.com/t')),
        throwsA(
          isA<ImportFailure>()
              .having((f) => f.reason, 'reason', ImportFailureReason.noRecipe)
              .having((f) => f.site, 'site', 'a.com'),
        ),
      );
    });
  });
}
