import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group('groceryKey', () {
    test('ignores case, punctuation, and spacing', () {
      expect(groceryKey('  Green   Onion '), 'green onion');
      expect(groceryKey('half-and-half'), 'half and half');
      expect(groceryKey('Crème fraîche'), 'crème fraîche');
    });

    test('gives a singular and its plural the same key', () {
      for (final (singular, plural) in [
        ('onion', 'onions'),
        ('berry', 'berries'),
        ('cookie', 'cookies'),
        ('tomato', 'tomatoes'),
        ('peach', 'peaches'),
        ('radish', 'radishes'),
        ('box', 'boxes'),
        ('glass', 'glasses'),
        ('egg', 'eggs'),
      ]) {
        expect(groceryKey(plural), groceryKey(singular), reason: plural);
      }
    });

    test('keeps an "s" that is not a plural', () {
      expect(groceryKey('asparagus'), 'asparagus');
      expect(groceryKey('swiss chard'), 'swiss chard');
      expect(groceryKey('pastis'), 'pastis');
    });

    test('leaves short words alone', () {
      expect(groceryKey('gas'), 'gas');
      expect(groceryKey('pie'), 'pie');
    });
  });
}
