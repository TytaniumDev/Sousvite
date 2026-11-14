import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/grocery/application/grocery_ids.dart';

void main() {
  group(GroceryIds, () {
    test('makes sort keys in order, even within one microsecond', () {
      var counter = 0;
      final ids = GroceryIds(newId: () => '${counter++}', nowMicros: () => 5);

      final keys = [ids.sortKey(), ids.sortKey(), ids.sortKey()];

      expect(keys.map((key) => key.value), [
        '00000000000000005',
        '00000000000000006',
        '00000000000000007',
      ]);
      expect(ids.listId().value, '0');
      expect(ids.itemId().value, '1');
    });

    test('random ids are unique and sort keys follow the clock', () {
      final ids = GroceryIds.random();

      expect(ids.itemId(), isNot(ids.itemId()));
      expect(ids.sortKey().value.compareTo(ids.sortKey().value), lessThan(0));
    });
  });
}
