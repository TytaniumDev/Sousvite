import 'package:sync/sync.dart';
import 'package:test/test.dart';

/// Makes transports that share one fresh, empty space.
abstract interface class TransportHarness() {
  /// A transport for [deviceId] in this harness's space. Every transport
  /// from one harness sees the same space.
  Future<SyncTransport> transportFor(String deviceId);

  /// Frees what the harness holds, such as emulator data.
  Future<void> dispose();
}

/// The behavior every [SyncTransport] must have (ENGINEERING.md §8.2,
/// BUILD_PLAN SYN-3). The in-memory, Google Drive, and Firestore
/// transports each run it.
///
/// It asks only for what the sync engine relies on: every change reaches
/// every device at least once, cursors resume without losing anything,
/// a pull from the start adds up to the space's full state, and no change
/// is ever removed (ENGINEERING.md §8.1). Exact batch sizes and duplicates
/// are left to each transport, because the engine's merge is idempotent.
void runTransportContract(
  String name,
  TransportHarness Function() createHarness,
) {
  group('$name transport contract', () {
    late TransportHarness harness;
    var sequence = 0;

    setUp(() {
      harness = createHarness();
      sequence = 0;
    });

    tearDown(() => harness.dispose());

    Change change(
      String deviceId,
      int millis, {
      String field = 'title',
      Object? value,
    }) => Change(
      id: '$deviceId-${sequence++}',
      entity: 'recipe',
      entityId: 'r1',
      field: field,
      value: value ?? 'v$millis',
      hlc: Hlc(millis, 0, deviceId),
      deviceId: deviceId,
      spaceId: 'private',
    );

    test('an empty space pulls nothing', () async {
      final phone = await harness.transportFor('phone');

      expect(await _pulledChanges(phone), isEmpty);
    });

    test('a pull from the start returns every pushed change', () async {
      final phone = await harness.transportFor('phone');
      final pushed = [for (var i = 0; i < 5; i++) change('phone', 1000 + i)];

      await phone.push(pushed);

      expect(await _pulledChanges(phone), containsAll(pushed));
    });

    test('changes from every device reach every device', () async {
      final phone = await harness.transportFor('phone');
      final laptop = await harness.transportFor('laptop');
      final fromPhone = change('phone', 1000);
      final fromLaptop = change('laptop', 2000, field: 'notes');

      await phone.push([fromPhone]);
      await laptop.push([fromLaptop]);

      expect(await _pulledChanges(phone), containsAll([fromPhone, fromLaptop]));
      expect(
        await _pulledChanges(laptop),
        containsAll([fromPhone, fromLaptop]),
      );
    });

    test('a pull from a cursor returns what came after it', () async {
      final phone = await harness.transportFor('phone');
      final laptop = await harness.transportFor('laptop');
      final early = change('phone', 1000);
      await phone.push([early]);
      final cursor = (await laptop.pull().toList()).last.cursor;

      final late = change('phone', 2000);
      await phone.push([late]);
      final after = await _pulledChanges(laptop, since: cursor);

      expect(after, contains(late));
      expect(after, isNot(contains(early)));
    });

    test('resuming from any cursor loses nothing', () async {
      final phone = await harness.transportFor('phone');
      final pushed = [for (var i = 0; i < 12; i++) change('phone', 1000 + i)];
      for (final change in pushed) {
        await phone.push([change]);
      }
      final batches = await phone.pull().toList();

      var seen = <Change>{};
      for (final batch in batches) {
        seen = {...seen, ...batch.changes};
        final rest = await _pulledChanges(phone, since: batch.cursor);
        expect({...seen, ...rest}, containsAll(pushed));
      }
    });

    test('pushing a change twice is harmless', () async {
      final phone = await harness.transportFor('phone');
      final title = change('phone', 1000);

      await phone.push([title]);
      await phone.push([title]);

      expect(await _pulledChanges(phone), contains(title));
      expect(_state(await _pulledChanges(phone)), {title.key: title});
    });

    test('a pull from the start begins with the latest snapshot', () async {
      final phone = await harness.transportFor('phone');
      final first = change('phone', 1000);
      final second = change('phone', 2000);
      await phone.push([first, second]);
      await phone.writeSnapshot(
        Snapshot(changes: [second], through: second.hlc),
      );
      final later = change('phone', 3000, field: 'servings', value: 4);
      await phone.push([later]);

      final tablet = await harness.transportFor('tablet');
      final batches = await tablet.pull().toList();

      expect(batches.first.changes, contains(second));
      expect(_state([for (final batch in batches) ...batch.changes]), {
        second.key: second,
        later.key: later,
      });
    });

    test('a newer snapshot replaces an older one', () async {
      final phone = await harness.transportFor('phone');
      final first = change('phone', 1000);
      final second = change('phone', 2000);
      await phone.push([first]);
      await phone.writeSnapshot(Snapshot(changes: [first], through: first.hlc));
      await phone.push([second]);
      await phone.writeSnapshot(
        Snapshot(changes: [second], through: second.hlc),
      );

      final tablet = await harness.transportFor('tablet');

      expect(_state(await _pulledChanges(tablet)), {second.key: second});
    });

    test('a snapshot with a cursor resumes the log after it', () async {
      final phone = await harness.transportFor('phone');
      final first = change('phone', 1000);
      await phone.push([first]);
      final cursor = (await phone.pull().toList()).last.cursor;
      await phone.writeSnapshot(
        Snapshot(changes: [first], through: first.hlc, pulledThrough: cursor),
      );
      final later = change('phone', 2000, field: 'notes');
      await phone.push([later]);

      final tablet = await harness.transportFor('tablet');
      final batches = await tablet.pull().toList();

      expect(batches.first.changes, contains(first));
      expect(_state([for (final batch in batches) ...batch.changes]), {
        first.key: first,
        later.key: later,
      });
      final resumed = await _pulledChanges(tablet, since: batches.last.cursor);
      expect(resumed, isNot(contains(later)));
    });

    test('a snapshot never removes changes from the log', () async {
      final phone = await harness.transportFor('phone');
      final pushed = [for (var i = 0; i < 4; i++) change('phone', 1000 + i)];
      await phone.push(pushed);
      await phone.writeSnapshot(
        Snapshot(changes: [pushed.last], through: pushed.last.hlc),
      );

      final tablet = await harness.transportFor('tablet');

      expect(await _pulledChanges(tablet), containsAll(pushed));
    });

    test('a device that pulled before a snapshot still catches up', () async {
      final phone = await harness.transportFor('phone');
      final laptop = await harness.transportFor('laptop');
      final early = change('phone', 1000);
      await phone.push([early]);
      final before = await laptop.pull().toList();
      final cursor = before.last.cursor;

      final notes = change('phone', 2000, field: 'notes');
      final title = change('phone', 3000);
      await phone.push([notes, title]);
      await phone.writeSnapshot(
        Snapshot(changes: [notes, title], through: title.hlc),
      );

      final caughtUp = [
        for (final batch in before) ...batch.changes,
        ...await _pulledChanges(laptop, since: cursor),
      ];
      expect(_state(caughtUp), {notes.key: notes, title.key: title});
    });
  });
}

Future<List<Change>> _pulledChanges(
  SyncTransport transport, {
  SyncCursor? since,
}) async => [
  await for (final batch in transport.pull(since: since)) ...batch.changes,
];

/// What a device ends up with after merging [changes].
Map<FieldKey, Change> _state(List<Change> changes) =>
    mergeAll(const {}, changes).winners;
