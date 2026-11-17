import 'dart:async';

import 'package:sync/sync.dart';
import 'package:test/test.dart';

import '../../contract/transport_contract.dart';
import '../../helpers/fake_firestore_space.dart';

final class _FirestoreHarness() implements TransportHarness {
  final server = FakeFirestoreServer();

  @override
  Future<SyncTransport> transportFor(String deviceId) async =>
      FirestoreTransport(FakeFirestoreSpace(server), pageSize: 2);

  @override
  Future<void> dispose() async {}
}

Change _change(int i, {String value = 'v'}) => Change(
  id: 'c$i',
  entity: 'recipe',
  entityId: 'r1',
  field: 'f$i',
  value: value,
  hlc: Hlc(1000 + i, 0, 'phone'),
  deviceId: 'phone',
  spaceId: 'private',
);

void main() {
  runTransportContract('Firestore', _FirestoreHarness.new);

  group(FirestoreTransport, () {
    late FakeFirestoreServer server;

    setUp(() => server = FakeFirestoreServer());

    test('pushing nothing writes nothing', () async {
      await FirestoreTransport(FakeFirestoreSpace(server)).push(const []);

      expect(server.batches, isEmpty);
      expect(server.created, 0);
    });

    test('creates the space once, before the first write', () async {
      final transport = FirestoreTransport(FakeFirestoreSpace(server));

      await transport.push([_change(0)]);
      await transport.push([_change(1)]);

      expect(server.created, 1);
    });

    test('tries to create the space again after a failure', () async {
      final transport = FirestoreTransport(FakeFirestoreSpace(server));
      server.failNextEnsure = true;

      await expectLater(transport.push([_change(0)]), throwsStateError);
      await transport.push([_change(0)]);

      expect(server.created, 1);
      expect(server.batches, hasLength(1));
    });

    test('splits a push into batches by count', () async {
      final transport = FirestoreTransport(
        FakeFirestoreSpace(server),
        maxChangesPerBatch: 2,
      );

      await transport.push([for (var i = 0; i < 5; i++) _change(i)]);

      expect(server.batches.map((batch) => batch.document.changes.length), [
        2,
        2,
        1,
      ]);
    });

    test('splits a push into batches by size', () async {
      final transport = FirestoreTransport(
        FakeFirestoreSpace(server),
        maxBatchBytes: 400,
      );

      await transport.push([
        for (var i = 0; i < 3; i++) _change(i, value: 'x' * 200),
      ]);

      expect(server.batches, hasLength(3));
    });

    test('stamps each batch with its device and highest HLC', () async {
      final transport = FirestoreTransport(FakeFirestoreSpace(server));

      await transport.push([_change(2), _change(1)]);

      final document = server.batches.single.document;
      expect(document.deviceId, 'phone');
      expect(document.hlcMax, const Hlc(1002, 0, 'phone').pack());
    });

    test('stores snapshots as files named by their HLC', () async {
      final transport = FirestoreTransport(FakeFirestoreSpace(server));
      const hlc = Hlc(5000, 0, 'phone');

      await transport.writeSnapshot(const Snapshot(changes: [], through: hlc));

      expect(server.latest, (
        path: 'snapshots/${hlc.pack()}.json.gz',
        hlc: hlc.pack(),
      ));
      expect(server.created, 1);
    });

    test('reports pushes from other devices', () async {
      final transport = FirestoreTransport(FakeFirestoreSpace(server));
      final events = <void>[];
      final subscription = transport.remoteChanges().listen(events.add);
      await pumpEventQueue();

      await FirestoreTransport(FakeFirestoreSpace(server)).push([_change(0)]);
      await pumpEventQueue();

      expect(events, hasLength(2));
      await subscription.cancel();
    });
  });
}
