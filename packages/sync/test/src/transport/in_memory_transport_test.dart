import 'package:sync/sync.dart';
import 'package:test/test.dart';

import '../../contract/transport_contract.dart';

final class _InMemoryHarness() implements TransportHarness {
  final space = InMemorySyncSpace();

  @override
  Future<SyncTransport> transportFor(String deviceId) async =>
      InMemoryTransport(space, batchSize: 3);

  @override
  Future<void> dispose() async {}
}

Change _change(String id, int millis, {String field = 'title'}) => Change(
  id: id,
  entity: 'recipe',
  entityId: 'r1',
  field: field,
  value: id,
  hlc: Hlc(millis, 0, 'phone'),
  deviceId: 'phone',
  spaceId: 'private',
);

void main() {
  runTransportContract('in-memory', _InMemoryHarness.new);

  group(InMemoryTransport, () {
    late InMemorySyncSpace space;
    late InMemoryTransport transport;

    setUp(() {
      space = InMemorySyncSpace();
      transport = InMemoryTransport(space);
    });

    test('keeps each change once', () async {
      final title = _change('a', 1000);

      await transport.push([title, title]);

      expect(space.changes, [title]);
    });

    test('a snapshot prunes the oldest changes it covers', () async {
      final first = _change('a', 1000);
      final notes = _change('b', 1500, field: 'notes');
      final second = _change('c', 2000);
      await transport.push([first, notes, second]);

      await transport.writeSnapshot(
        Snapshot(changes: [second], through: second.hlc),
      );

      // `first` is covered by `second`; `notes` is not, so pruning stops.
      expect(space.changes, [notes, second]);
      expect(space.snapshot?.changes, [second]);
    });

    test(
      'a cursor from before the pruned part restarts at the snapshot',
      () async {
        final first = _change('a', 1000);
        await transport.push([first]);
        final oldCursor = (await transport.pull().toList()).last.cursor;
        final second = _change('b', 2000);
        final third = _change('c', 3000);
        await transport.push([second, third]);
        await transport.writeSnapshot(
          Snapshot(changes: [third], through: third.hlc),
        );

        final batches = await transport.pull(since: oldCursor).toList();

        expect(batches.first.changes, [third]);
        expect(batches.last.cursor, const SyncCursor('3'));
      },
    );
  });
}
