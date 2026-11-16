// Keys are created at runtime on purpose, as they are in app code.
// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group(SortKey, () {
    test('orders as plain strings', () {
      final keys = [SortKey('b'), SortKey('a0'), SortKey('a')];

      final sorted = [...keys]..sort();

      expect(sorted, const [SortKey('a'), SortKey('a0'), SortKey('b')]);
    });

    group('between', () {
      void expectBetween(SortKey? before, SortKey? after) {
        final key = SortKey.between(before, after);
        if (before != null) expect(key.compareTo(before.value), 1);
        if (after != null) expect(key.compareTo(after.value), -1);
        expect(key.value, isNot(endsWith('0')));
      }

      test('starts a list in the middle', () {
        expect(SortKey.between(null, null), SortKey('V'));
      });

      test('fits between neighbours, at the ends, and adjacent digits', () {
        expectBetween(SortKey('a'), SortKey('b'));
        expectBetween(SortKey('a'), null);
        expectBetween(null, SortKey('a'));
        expectBetween(null, SortKey('01'));
        expectBetween(SortKey('a1'), SortKey('a2'));
        expectBetween(SortKey('az'), SortKey('b'));
        expectBetween(SortKey('a'), SortKey('a1'));
        expectBetween(SortKey('zz'), null);
      });

      test('rejects keys out of order', () {
        expect(
          () => SortKey.between(SortKey('b'), SortKey('a')),
          throwsArgumentError,
        );
        expect(
          () => SortKey.between(SortKey('a'), SortKey('a')),
          throwsArgumentError,
        );
      });

      test('keeps any order through many random inserts', () {
        final random = Random(7);
        final keys = <SortKey>[];
        for (var i = 0; i < 500; i++) {
          final at = random.nextInt(keys.length + 1);
          final key = SortKey.between(
            at == 0 ? null : keys[at - 1],
            at == keys.length ? null : keys[at],
          );
          keys.insert(at, key);
        }
        expect([...keys]..sort(), keys);
        expect(keys.toSet(), hasLength(keys.length));
      });
    });

    test('sequence makes keys in order', () {
      final keys = SortKey.sequence(40);
      expect(keys, hasLength(40));
      expect([...keys]..sort(), keys);
    });
  });
}
