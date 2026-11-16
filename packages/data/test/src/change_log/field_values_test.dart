import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group('field values', () {
    test('round-trip a quantity as numerator and denominator', () {
      expect(encodeQuantity(Quantity(3, 2)), {'n': 3, 'd': 2});
      expect(decodeQuantity({'n': 3, 'd': 2}), Quantity(3, 2));
      expect(encodeQuantity(null), isNull);
      expect(decodeQuantity(null), isNull);
      expect(decodeQuantity('1/2'), isNull);
    });

    test('round-trip a duration as seconds', () {
      expect(encodeDuration(const Duration(minutes: 2)), 120);
      expect(decodeDuration(120), const Duration(minutes: 2));
      expect(encodeDuration(null), isNull);
      expect(decodeDuration('2m'), isNull);
    });

    test('round-trip a time as UTC text', () {
      final time = DateTime.utc(2026, 11, 16, 9, 30);

      expect(encodeDateTime(time), '2026-11-16T09:30:00.000Z');
      expect(decodeDateTime('2026-11-16T09:30:00.000Z'), time);
      expect(encodeDateTime(null), isNull);
      expect(decodeDateTime(42), isNull);
    });

    test('round-trip an enum by name and ignore unknown names', () {
      expect(encodeEnum(Unit.cup), 'cup');
      expect(decodeEnum(Unit.values, 'cup'), Unit.cup);
      expect(decodeEnum(Unit.values, 'smidgen'), isNull);
      expect(encodeEnum(null), isNull);
    });
  });
}
