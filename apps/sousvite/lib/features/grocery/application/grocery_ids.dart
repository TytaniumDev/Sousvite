import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'grocery_ids.g.dart';

/// Makes ids and sort keys for new grocery lists and items. Tests override
/// [groceryIdsProvider] for predictable values.
class GroceryIds({
  /// Makes a new unique id.
  required final String Function() newId,

  /// The current time in microseconds, for sort keys.
  required final int Function() nowMicros,
}) {
  /// Uses random UUIDs and the system clock.
  factory random() {
    const uuid = Uuid();
    return GroceryIds(
      newId: uuid.v4,
      nowMicros: () => DateTime.now().microsecondsSinceEpoch,
    );
  }

  var _lastMicros = 0;

  GroceryListId listId() => GroceryListId(newId());

  GroceryItemId itemId() => GroceryItemId(newId());

  /// A key after every key made before it, so new items go to the end.
  ///
  /// New items are only ever appended. Moving items between others needs
  /// the fractional index helper `SortKey` is waiting for.
  SortKey sortKey() {
    final micros = nowMicros();
    _lastMicros = micros > _lastMicros ? micros : _lastMicros + 1;
    return SortKey(_lastMicros.toString().padLeft(_width, '0'));
  }

  // Wide enough for microsecond timestamps for the next few hundred years.
  static const _width = 17;
}

@riverpod
GroceryIds groceryIds(Ref ref) => GroceryIds.random();
