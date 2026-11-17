import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:sync/sync.dart';
import 'package:test/test.dart';

import '../../helpers/test_device.dart';

/// A test device with a grocery repository.
final class _Device(super.id, super.space) extends TestDevice {
  late final grocery = DriftGroceryRepository(database, recorder: recorder);

  @override
  Map<String, EntityApplier> get appliers => grocery.appliers;
}

GroceryList _list(String id, String name, {int day = 0}) => GroceryList(
  id: GroceryListId(id),
  name: name,
  createdAt: DateTime.utc(2026, 11, 16).add(Duration(days: day)),
);

const _weekly = GroceryListId('g1');

GroceryItem _item(String id, String name, {String sortKey = 'a'}) =>
    GroceryItem(
      id: GroceryItemId(id),
      listId: _weekly,
      name: name,
      sortKey: SortKey(sortKey),
    );

void main() {
  late InMemorySyncSpace space;
  late List<_Device> devices;

  _Device device(String id) {
    final created = _Device(id, space);
    devices.add(created);
    return created;
  }

  setUp(() {
    space = InMemorySyncSpace();
    devices = [];
  });

  tearDown(() async {
    for (final device in devices) {
      await device.database.close();
    }
  });

  group(DriftGroceryRepository, () {
    test('lists grocery lists oldest first', () async {
      final grocery = device('phone').grocery;
      await grocery.saveList(_list('g2', 'Party', day: 1));
      await grocery.saveList(_list('g1', 'Weekly'));

      expect(await grocery.watchLists().first, [
        _list('g1', 'Weekly'),
        _list('g2', 'Party', day: 1),
      ]);
    });

    test('saves items with every field and lists them in order', () async {
      final grocery = device('phone').grocery;
      final garlic = GroceryItem(
        id: const GroceryItemId('i1'),
        listId: _weekly,
        name: 'garlic',
        sortKey: const SortKey('b'),
        quantity: Quantity(5),
        countWord: 'clove',
        storeSection: 'Produce',
        checked: true,
        sourceIngredientLineId: const IngredientLineId('l1'),
        sourceRecipeId: const RecipeId('r1'),
      );
      final milk = _item(
        'i2',
        'milk',
      ).copyWith(quantity: Quantity(1, 2), unit: Unit.gallon);

      await grocery.saveItem(garlic);
      await grocery.saveItem(milk);

      expect(await grocery.watchItems(_weekly).first, [milk, garlic]);
    });

    test('checking an item off records only checked', () async {
      final phone = device('phone');
      final milk = _item('i1', 'milk');
      await phone.grocery.saveItem(milk);
      final before = (await phone.changes()).length;

      await phone.grocery.saveItem(milk.copyWith(checked: true));

      final added = (await phone.changes()).skip(before);
      expect(added.map((change) => (change.field, change.value)), [
        ('checked', true),
      ]);
    });

    test('deletes an item, and a list with its items', () async {
      final phone = device('phone');
      await phone.grocery.saveList(_list('g1', 'Weekly'));
      await phone.grocery.saveItem(_item('i1', 'milk'));
      await phone.grocery.saveItem(_item('i2', 'eggs', sortKey: 'b'));

      await phone.grocery.deleteItem(const GroceryItemId('i1'));
      expect(await phone.grocery.watchItems(_weekly).first, [
        _item('i2', 'eggs', sortKey: 'b'),
      ]);

      await phone.grocery.deleteList(_weekly);
      expect(await phone.grocery.watchLists().first, isEmpty);
      expect(await phone.grocery.watchItems(_weekly).first, isEmpty);
      expect(await phone.tombstones(), {'i1', 'i2', 'g1'});
    });

    test('emits items again only when they change', () async {
      final phone = device('phone');
      await phone.grocery.saveItem(_item('i1', 'milk'));
      final names = <List<String>>[];
      final subscription = phone.grocery
          .watchItems(_weekly)
          .listen((items) => names.add([for (final i in items) i.name]));
      await pumpEventQueue();

      await phone.grocery.saveList(_list('g1', 'Weekly'));
      await pumpEventQueue();
      await phone.grocery.saveItem(_item('i1', 'oat milk'));
      await pumpEventQueue();

      expect(names, [
        ['milk'],
        ['oat milk'],
      ]);
      await subscription.cancel();
    });

    test('merges two people checking off different items', () async {
      final phone = device('phone');
      final laptop = device('laptop');
      final milk = _item('i1', 'milk');
      final eggs = _item('i2', 'eggs', sortKey: 'b');
      await phone.grocery.saveList(_list('g1', 'Weekly'));
      await phone.grocery.saveItem(milk);
      await phone.grocery.saveItem(eggs);
      await phone.engine.sync();
      await laptop.engine.sync();

      await phone.grocery.saveItem(milk.copyWith(checked: true));
      await laptop.grocery.saveItem(eggs.copyWith(checked: true));
      await phone.engine.sync();
      await laptop.engine.sync();
      await phone.engine.sync();

      final both = [milk.copyWith(checked: true), eggs.copyWith(checked: true)];
      expect(await phone.grocery.watchItems(_weekly).first, both);
      expect(await laptop.grocery.watchItems(_weekly).first, both);
      expect(await laptop.grocery.watchLists().first, [_list('g1', 'Weekly')]);

      await phone.grocery.deleteList(_weekly);
      await phone.engine.sync();
      await laptop.engine.sync();
      expect(await laptop.grocery.watchLists().first, isEmpty);
      expect(await laptop.grocery.watchItems(_weekly).first, isEmpty);
    });
  });

  group('grocery codecs', () {
    test('wait for every required field', () {
      expect(GroceryListCodec().decode('g1', {'name': 'Weekly'}), isNull);
      expect(GroceryItemCodec().decode('i1', {'name': 'milk'}), isNull);
    });
  });
}
