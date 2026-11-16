import 'package:data/data.dart';
import 'package:drift/native.dart';
import 'package:sync/sync.dart';
import 'package:test/test.dart';

/// Records what it was asked to apply, standing in for a repository's
/// applier.
final class _RecordingApplier() implements EntityApplier {
  final applied = <Change>[];

  @override
  Future<void> apply(Change change) async => applied.add(change);
}

/// One simulated device: a database, a recorder for local writes, and a
/// sync engine over a shared in-memory space.
final class _Device(
  final String id,
  final InMemorySyncSpace space, {
  final int time = 1000,
}) {
  final database = AppDatabase(NativeDatabase.memory());
  late final HybridLogicalClock clock = HybridLogicalClock(
    id,
    wallClock: () => time,
  );
  final recipes = _RecordingApplier();
  final preserved = <Change>[];
  var _ids = 0;

  late final DriftLocalStore store = DriftLocalStore(
    database,
    deviceId: id,
    appliers: {'recipe': recipes},
    onPreserved: (changes) async => preserved.addAll(changes),
    now: () => DateTime.utc(2026, 11, 15),
  );
  late final recorder = ChangeRecorder(
    database,
    clock: clock,
    spaceId: 'private',
    newId: () => '${clock.nodeId}-${_ids++}',
  );
  late final SyncEngine engine = SyncEngine(
    store: store,
    transport: InMemoryTransport(space, batchSize: 2),
    clock: clock,
    transportKey: 'memory',
    spaceId: 'private',
    policy: const MergePolicy(
      longTextFields: {(entity: 'recipe', field: 'notes')},
    ),
  );

  Future<void> edit(Map<String, Object?> fields, {String id = 'r1'}) =>
      recorder.write((changes) async => changes.set('recipe', id, fields));

  Future<Set<Change>> state() async => {
    ...await store.allWinners(spaceId: 'private'),
  };
}

void main() {
  late InMemorySyncSpace space;
  late List<_Device> devices;

  _Device device(String id, {int time = 1000}) {
    final created = _Device(id, space, time: time);
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

  group(DriftLocalStore, () {
    test(
      "lists only this device's changes in the space, after a time",
      () async {
        final phone = device('phone');
        await phone.edit({'title': 'Soup', 'servings': 2});
        await phone.recorder.write(
          (changes) async =>
              changes.set('recipe', 'r2', {'title': 'Shared'}, spaceId: 's1'),
        );
        await phone.store.applyRemote(
          winners: [
            const Change(
              id: 'remote',
              entity: 'recipe',
              entityId: 'r3',
              field: 'title',
              value: 'Theirs',
              hlc: Hlc(500, 0, 'laptop'),
              deviceId: 'laptop',
              spaceId: 'private',
            ),
          ],
          preserved: const [],
        );

        final all = await phone.store.ownChangesAfter(null, spaceId: 'private');
        final later = await phone.store.ownChangesAfter(
          all.first.hlc,
          spaceId: 'private',
        );

        expect(all.map((change) => change.field), ['title', 'servings']);
        expect(later.map((change) => change.field), ['servings']);
      },
    );

    test('finds current winners and leaves out unknown fields', () async {
      final phone = device('phone');
      await phone.edit({'title': 'Soup'});
      await phone.edit({'title': 'Stew'});
      const title = (entity: 'recipe', entityId: 'r1', field: 'title');
      const missing = (entity: 'recipe', entityId: 'r9', field: 'title');

      final winners = await phone.store.winnersFor({title, missing});

      expect(winners.keys, [title]);
      expect(winners[title]?.value, 'Stew');
    });

    test('lists the winning change of every field in a space', () async {
      final phone = device('phone');
      await phone.edit({'title': 'Soup', 'servings': 2});
      await phone.edit({'title': 'Stew'});
      await phone.edit({'title': 'Other'}, id: 'r2');

      final state = await phone.store.allWinners(spaceId: 'private');

      expect(
        {
          for (final change in state)
            '${change.entityId}.${change.field}': change.value,
        },
        {'r1.title': 'Stew', 'r1.servings': 2, 'r2.title': 'Other'},
      );
    });

    test('applies remote winners through the entity applier', () async {
      final phone = device('phone');
      const remote = Change(
        id: 'remote',
        entity: 'recipe',
        entityId: 'r1',
        field: 'title',
        value: 'Theirs',
        hlc: Hlc(500, 0, 'laptop'),
        deviceId: 'laptop',
        spaceId: 'private',
      );
      const unknown = Change(
        id: 'other',
        entity: 'grocery_item',
        entityId: 'g1',
        field: 'name',
        value: 'Milk',
        hlc: Hlc(600, 0, 'laptop'),
        deviceId: 'laptop',
        spaceId: 'private',
      );

      await phone.store.applyRemote(
        winners: [remote, unknown],
        preserved: const [],
      );

      expect(phone.recipes.applied, [remote]);
      // An entity with no applier yet still keeps its change.
      expect(await phone.state(), {remote, unknown});
      expect(phone.preserved, isEmpty);
    });

    test('keeps preserved edits in the change log and hands them on', () async {
      final phone = device('phone');
      const lost = Change(
        id: 'lost',
        entity: 'recipe',
        entityId: 'r1',
        field: 'notes',
        value: 'Add lemon.',
        hlc: Hlc(500, 0, 'laptop'),
        deviceId: 'laptop',
        spaceId: 'private',
      );

      await phone.store.applyRemote(winners: const [], preserved: [lost]);

      expect(phone.preserved, [lost]);
      expect(phone.recipes.applied, isEmpty);
      expect(await phone.state(), {lost});
    });

    test('saves and reads sync progress', () async {
      final phone = device('phone');
      const progress = SyncProgress(
        pullCursor: SyncCursor('7'),
        pushedThrough: Hlc(1000, 2, 'phone'),
      );

      expect(await phone.store.progress('memory'), const SyncProgress());

      await phone.store.saveProgress('memory', progress);
      final row = await phone.database.syncDao.syncStateFor('memory');

      expect(await phone.store.progress('memory'), progress);
      expect(row?.lastSyncedAt, DateTime.utc(2026, 11, 15));
    });

    test('runs work in one database transaction', () async {
      final phone = device('phone');

      final failing = phone.store.transaction<void>(() async {
        await phone.edit({'title': 'Soup'});
        throw StateError('killed');
      });

      await expectLater(failing, throwsStateError);
      expect(await phone.state(), isEmpty);
    });
  });

  group('sync over Drift', () {
    test(
      'two devices converge, and the loser of a notes edit is kept',
      () async {
        final phone = device('phone');
        final laptop = device('laptop', time: 2000);
        await phone.edit({'title': 'Soup', 'notes': 'Add lemon.'});
        await laptop.edit({'notes': 'Use less salt.', 'servings': 4});

        for (var round = 0; round < 2; round++) {
          await phone.engine.sync();
          await laptop.engine.sync();
        }

        expect(await phone.state(), await laptop.state());
        expect(
          (await phone.state()).map((change) => change.value),
          containsAll(['Soup', 'Use less salt.', 4]),
        );
        expect(laptop.preserved.map((change) => change.value), ['Add lemon.']);
        expect(
          phone.recipes.applied.map((change) => change.field),
          containsAll(['notes', 'servings']),
        );
      },
    );
  });
}
