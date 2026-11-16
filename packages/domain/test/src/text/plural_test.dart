import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group('pluralOf', () {
    test('adds "s" to most words', () {
      expect(pluralOf('clove'), 'cloves');
      expect(pluralOf('can'), 'cans');
      expect(pluralOf('tray'), 'trays');
    });

    test('adds "es" after s, x, z, ch, and sh', () {
      expect(pluralOf('glass'), 'glasses');
      expect(pluralOf('box'), 'boxes');
      expect(pluralOf('spritz'), 'spritzes');
      expect(pluralOf('bunch'), 'bunches');
      expect(pluralOf('dash'), 'dashes');
    });

    test('turns a "y" after a consonant into "ies"', () {
      expect(pluralOf('berry'), 'berries');
    });

    test('knows the irregular words recipes use', () {
      expect(pluralOf('leaf'), 'leaves');
      expect(pluralOf('loaf'), 'loaves');
      expect(pluralOf('half'), 'halves');
      expect(pluralOf('knife'), 'knives');
    });
  });
}
