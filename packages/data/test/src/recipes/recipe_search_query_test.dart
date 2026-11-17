import 'package:data/data.dart';
import 'package:test/test.dart';

void main() {
  group('recipeSearchMatch', () {
    test('matches the start of every word', () {
      expect(recipeSearchMatch(' chick  tikka '), '"chick"* "tikka"*');
    });

    test('searches quotes and operators as text', () {
      expect(recipeSearchMatch('"mac" OR cheese'), '"mac"* "OR"* "cheese"*');
    });

    test('is null when there is nothing to search for', () {
      expect(recipeSearchMatch(''), isNull);
      expect(recipeSearchMatch('  "" '), isNull);
    });
  });
}
