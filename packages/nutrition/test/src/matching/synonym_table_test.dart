import 'package:nutrition/src/matching/food_text.dart';
import 'package:nutrition/src/matching/synonym_table.dart';
import 'package:test/test.dart';

void main() {
  group(SynonymTable, () {
    List<String> apply(SynonymTable table, String name) =>
        table.apply(foodTokens(name));

    test('rewrites phrases wherever they appear', () {
      final table = SynonymTable(phrases: {'scallion': 'green onion'});

      expect(apply(table, 'sliced scallions'), ['sliced', 'green', 'onion']);
    });

    test('prefers the longest phrase', () {
      final table = SynonymTable(
        phrases: {'salt': 'table salt', 'kosher salt': 'coarse salt'},
      );

      expect(apply(table, 'kosher salt'), ['coarse', 'salt']);
      expect(apply(table, 'salt'), ['table', 'salt']);
    });

    test('removes phrases that map to nothing', () {
      final table = SynonymTable(phrases: {'chopped': '', 'to taste': ''});

      expect(apply(table, 'chopped parsley to taste'), ['parsley']);
    });

    test('rewrites a whole name with its default only', () {
      final table = SynonymTable(defaults: {'milk': 'whole milk'});

      expect(apply(table, 'Milk'), ['whole', 'milk']);
      expect(apply(table, 'coconut milk'), ['coconut', 'milk']);
    });

    test('applies defaults after phrases', () {
      final table = SynonymTable(
        phrases: {'cold': ''},
        defaults: {'milk': 'whole milk'},
      );

      expect(apply(table, 'cold milk'), ['whole', 'milk']);
    });

    test('leaves names without rules alone', () {
      expect(apply(SynonymTable(), 'honey'), ['honey']);
    });
  });
}
