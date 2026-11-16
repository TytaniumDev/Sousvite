import 'package:nutrition/nutrition.dart';
import 'package:test/test.dart';

void main() {
  group('densityOf', () {
    test('finds an ingredient by whole word, ignoring case and plurals', () {
      expect(densityOf('All-purpose Flour'), 0.53);
      expect(densityOf('rolled oats'), 0.38);
      expect(densityOf('Oil, olive, salad or cooking'), 0.92);
    });

    test('prefers the longest entry', () {
      expect(densityOf('packed brown sugar'), 0.93);
      expect(densityOf('granulated sugar'), 0.85);
      expect(densityOf('cream cheese'), 0.97);
      expect(densityOf('whole wheat flour'), 0.51);
    });

    test('is null when nothing matches', () {
      expect(densityOf('chopped onion'), isNull);
      expect(densityOf('cornflakes'), isNull);
    });

    test('takes another table', () {
      expect(densityOf('ghee', table: const {'ghee': 0.91}), 0.91);
    });
  });
}
