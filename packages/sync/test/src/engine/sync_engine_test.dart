import 'dart:math';

import 'package:sync/sync.dart';
import 'package:test/test.dart';

import '../../helpers/fakes.dart';

const _notesPolicy = MergePolicy(
  longTextFields: {(entity: 'recipe', field: 'notes')},
);

/// One simulated device: its clock, database, and engine.
final class _Device(
  String id,
  final FakeTransport transport, {
  int Function()? wallClock,
}) {
  final HybridLogicalClock clock = HybridLogicalClock(
    id,
    wallClock: wallClock ?? () => 1000,
  );
  late final store = FakeLocalStore(clock);
  late final SyncEngine engine = SyncEngine(
    store: store,
    transport: transport,
    clock: clock,
    transportKey: 'fake',
    spaceId: 'private',
    policy: _notesPolicy,
  );
}

void main() {
  late FakeTransport transport;

  setUp(() => transport = FakeTransport());

  group(SyncEngine, () {
    group('push', () {
      test('sends own changes in this space once', () async {
        final phone = _Device('phone', transport);
        final title = phone.store.write('title', 'Soup');
        phone.store.write('title', 'Shared', spaceId: 'share1');

        expect(await phone.engine.push(), 1);
        expect(await phone.engine.push(), 0);
        expect(transport.log, [title]);
        expect(
          await phone.store.progress('fake'),
          SyncProgress(pushedThrough: title.hlc),
        );
      });

      test('does not send changes it received from others', () async {
        final phone = _Device('phone', transport);
        final laptop = _Device('laptop', transport);
        phone.store.write('title', 'Soup');
        await phone.engine.sync();

        await laptop.engine.sync();

        expect(await laptop.engine.push(), 0);
        expect(transport.log, hasLength(1));
      });
    });

    group('pull', () {
      test(
        'applies newer remote changes and moves the clock past them',
        () async {
          final phone = _Device('phone', transport);
          final laptop = _Device('laptop', transport, wallClock: () => 5000);
          final remote = laptop.store.write('title', 'Stew');
          await laptop.engine.push();

          final report = await phone.engine.sync();
          final local = phone.store.write('title', 'Chili');

          expect(report, (pushed: 0, applied: 1, preserved: 0));
          expect(local.hlc > remote.hlc, isTrue);
        },
      );

      test('keeps a newer local edit over an older remote one', () async {
        var phoneTime = 1000;
        final phone = _Device('phone', transport, wallClock: () => phoneTime);
        final laptop = _Device('laptop', transport);
        laptop.store.write('title', 'Stew');
        await laptop.engine.push();
        phoneTime = 2000;
        final local = phone.store.write('title', 'Chili');

        final report = await phone.engine.pull();

        expect(report, (applied: 0, preserved: 0));
        expect(phone.store.winners[local.key], local);
      });

      test('keeps a losing concurrent notes edit in history', () async {
        var phoneTime = 1000;
        final phone = _Device('phone', transport, wallClock: () => phoneTime);
        final laptop = _Device('laptop', transport);
        final theirs = laptop.store.write('notes', 'Add lemon.');
        await laptop.engine.push();
        phoneTime = 2000;
        phone.store.write('notes', 'Use less salt.');

        final report = await phone.engine.pull();

        expect(report.preserved, 1);
        expect(phone.store.history, [theirs]);
      });

      test('picks up where an interrupted pull stopped', () async {
        transport = FakeTransport(batchSize: 1);
        final phone = _Device('phone', transport);
        final laptop = _Device('laptop', transport);
        laptop.store
          ..write('title', 'Stew')
          ..write('servings', 4);
        await laptop.engine.push();

        phone.store.failNextApply = true;
        await expectLater(phone.engine.pull(), throwsStateError);
        // The first batch failed, so nothing moved on.
        expect(await phone.store.progress('fake'), const SyncProgress());

        final report = await phone.engine.pull();

        expect(report.applied, 2);
        expect(phone.store.winners, laptop.store.winners);
      });

      test('pulling the same changes again changes nothing', () async {
        final phone = _Device('phone', transport);
        final laptop = _Device('laptop', transport);
        laptop.store.write('title', 'Stew');
        await laptop.engine.push();
        await phone.engine.pull();

        await phone.store.saveProgress('fake', const SyncProgress());
        final again = await phone.engine.pull();

        expect(again, (applied: 0, preserved: 0));
      });
    });

    group('snapshots', () {
      test('a new device starts from the latest snapshot', () async {
        final phone = _Device('phone', transport);
        phone.store
          ..write('title', 'Soup')
          ..write('title', 'Stew')
          ..write('servings', 4);
        await phone.engine.sync();
        await phone.engine.writeSnapshot();
        transport.log.clear(); // As if the transport pruned what it covers.

        final tablet = _Device('tablet', transport);
        await tablet.engine.sync();

        expect(transport.snapshot?.changes, hasLength(2));
        expect(transport.snapshot?.through, phone.clock.latest);
        expect(tablet.store.winners, phone.store.winners);
      });

      test('replay copies everything into a new transport', () async {
        final phone = _Device('phone', transport);
        final laptop = _Device('laptop', transport);
        laptop.store.write('servings', 4);
        await laptop.engine.sync();
        phone.store.write('title', 'Soup');
        await phone.engine.sync();

        final cloud = FakeTransport();
        final phoneOnCloud = SyncEngine(
          store: phone.store,
          transport: cloud,
          clock: phone.clock,
          transportKey: 'cloud',
          spaceId: 'private',
        );
        await phoneOnCloud.replay();
        final later = phone.store.write('title', 'Stew');

        expect(await phoneOnCloud.push(), 1);
        expect(cloud.log, [later]);
        final tablet = _Device('tablet', cloud);
        await tablet.engine.sync();
        expect(tablet.store.winners, phone.store.winners);
      });

      test('replay with no own changes only writes the snapshot', () async {
        final phone = _Device('phone', transport);

        await phone.engine.replay();

        expect(transport.snapshot?.changes, isEmpty);
        expect(await phone.store.progress('fake'), const SyncProgress());
      });
    });
  });

  group('convergence', () {
    for (var seed = 0; seed < 20; seed++) {
      test('every device ends with the same state (seed $seed)', () async {
        final random = Random(seed);
        transport = FakeTransport(batchSize: 1 + random.nextInt(4));
        var now = 1731600000000;
        final devices = [
          for (var i = 0; i < 2 + random.nextInt(3); i++)
            _Device(
              'device$i',
              transport,
              wallClock: () {
                now += random.nextInt(3);
                return now + i * 7000 - 10000;
              },
            ),
        ];
        const fields = ['title', 'notes', 'servings', Change.deletedField];

        for (var step = 0; step < 150; step++) {
          final device = devices[random.nextInt(devices.length)];
          if (random.nextInt(3) > 0) {
            device.store.write(
              fields[random.nextInt(fields.length)],
              random.nextInt(4),
              entityId: 'r${random.nextInt(3)}',
            );
          } else {
            await device.engine.sync();
          }
        }
        for (var round = 0; round < 2; round++) {
          for (final device in devices) {
            await device.engine.sync();
          }
        }

        for (final device in devices.skip(1)) {
          expect(device.store.winners, devices.first.store.winners);
        }
      });
    }
  });
}
