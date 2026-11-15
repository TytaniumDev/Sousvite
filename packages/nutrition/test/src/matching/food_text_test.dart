import 'package:nutrition/src/matching/food_text.dart';
import 'package:test/test.dart';

void main() {
  group('foodTokens', () {
    test('lowercases, splits on punctuation, and drops stop words', () {
      expect(foodTokens('Cream of Tartar'), ['cream', 'tartar']);
      expect(foodTokens('All-purpose flour, sifted'), [
        'all',
        'purpose',
        'flour',
        'sifted',
      ]);
    });

    test('keeps numbers', () {
      expect(foodTokens('Milk, 2% milkfat'), ['milk', '2', 'milkfat']);
    });

    test('makes words singular', () {
      expect(foodTokens('Eggs and tomatoes'), ['egg', 'tomato']);
    });

    test('gives nothing for text without words', () {
      expect(foodTokens(' , - '), isEmpty);
    });
  });

  group('singular', () {
    final cases = {
      'eggs': 'egg',
      'berries': 'berry',
      'tomatoes': 'tomato',
      'peaches': 'peach',
      'radishes': 'radish',
      'boxes': 'box',
      'leaves': 'leaf',
      'halves': 'half',
      'loaves': 'loaf',
      'cloves': 'clove',
      'olives': 'olive',
      'hummus': 'hummus',
      'swiss': 'swiss',
      'peas': 'pea',
      'oil': 'oil',
    };
    for (final MapEntry(key: plural, value: expected) in cases.entries) {
      test('$plural → $expected', () => expect(singular(plural), expected));
    }
  });
}
