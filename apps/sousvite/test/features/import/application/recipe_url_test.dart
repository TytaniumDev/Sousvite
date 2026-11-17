import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/import/application/recipe_url.dart';

void main() {
  group('parseRecipeUrl', () {
    test('reads a full link', () {
      expect(
        parseRecipeUrl(' https://www.seriouseats.com/chili \n'),
        Uri.parse('https://www.seriouseats.com/chili'),
      );
    });

    test('adds https to a bare address', () {
      expect(
        parseRecipeUrl('cooking.nytimes.com/recipes/1'),
        Uri.parse('https://cooking.nytimes.com/recipes/1'),
      );
    });

    test('keeps http', () {
      expect(parseRecipeUrl('http://a.com'), Uri.parse('http://a.com'));
    });

    test('finds the link in shared text', () {
      expect(
        parseRecipeUrl('Best chili ever\nhttps://a.com/chili via @friend'),
        Uri.parse('https://a.com/chili'),
      );
      expect(parseRecipeUrl('see https://localhost/x'), isNull);
    });

    test('rejects text that is not a web address', () {
      for (final text in [
        '',
        'chili',
        'best chili recipe',
        'chili at a.com',
        'ftp://a.com/x',
        'https://localhost/x',
        'https://a./x',
        'http://[::1',
      ]) {
        expect(parseRecipeUrl(text), isNull, reason: text);
      }
    });
  });
}
