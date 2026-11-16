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

    test('a snapshot keeps every change', () async {
      final first = _change('a', 1000);
      final second = _change('b', 2000);
      await transport.push([first, second]);

      await transport.writeSnapshot(
        Snapshot(changes: [second], through: second.hlc),
      );

      expect(space.changes, [first, second]);
      expect(space.snapshot?.changes, [second]);
    });

    test('a pull from the start skips the log the snapshot covers', () async {
      final first = _change('a', 1000);
      await transport.push([first]);
      final cursor = (await transport.pull().toList()).last.cursor;
      await transport.writeSnapshot(
        Snapshot(changes: [first], through: first.hlc, pulledThrough: cursor),
      );
      final second = _change('b', 2000);
      await transport.push([second]);

      final batches = await transport.pull().toList();

      expect(batches.map((batch) => batch.changes), [
        [first],
        [second],
      ]);
      expect(batches.last.cursor, const SyncCursor('2'));
    });
  });
}
