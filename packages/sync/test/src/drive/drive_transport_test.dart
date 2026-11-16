import 'dart:typed_data';

import 'package:sync/sync.dart';
import 'package:test/test.dart';

import '../../contract/transport_contract.dart';
import '../../helpers/fake_drive_app_folder.dart';

final class _DriveHarness() implements TransportHarness {
  final drive = FakeDrive();

  @override
  Future<SyncTransport> transportFor(String deviceId) async =>
      DriveTransport(FakeDriveAppFolder(drive), deviceId: deviceId);

  @override
  Future<void> dispose() async {}
}

Change _change(String device, int i) => Change(
  id: '$device-$i',
  entity: 'recipe',
  entityId: 'r1',
  field: 'f$i',
  value: 'v$i',
  hlc: Hlc(1000 + i, 0, device),
  deviceId: device,
  spaceId: 'private',
);

Future<List<Change>> _pulled(
  SyncTransport transport, {
  SyncCursor? since,
}) async => [
  await for (final batch in transport.pull(since: since)) ...batch.changes,
];

void main() {
  runTransportContract('Google Drive', _DriveHarness.new);

  group(DriveTransport, () {
    late FakeDrive drive;
    final waits = <Duration>[];

    DriveTransport transportFor(String deviceId, {int maxAttempts = 6}) =>
        DriveTransport(
          FakeDriveAppFolder(drive),
          deviceId: deviceId,
          maxAttempts: maxAttempts,
          wait: (duration) async => waits.add(duration),
        );

    setUp(() {
      drive = FakeDrive();
      waits.clear();
    });

    test('writes one numbered file per push and never deletes', () async {
      final phone = transportFor('phone');

      await phone.push([_change('phone', 0), _change('phone', 1)]);
      await phone.push(const []);
      await phone.push([_change('phone', 2)]);

      expect(drive.files.map((file) => file.name), [
        'changes/phone/0000000001.json',
        'changes/phone/0000000002.json',
      ]);
    });

    test('a new session continues its own numbering', () async {
      await transportFor('phone').push([_change('phone', 0)]);
      await transportFor('laptop').push([_change('laptop', 0)]);

      await transportFor('phone').push([_change('phone', 1)]);

      expect(drive.files.last.name, 'changes/phone/0000000002.json');
    });

    test('a file listed late is read on a later pull', () async {
      final phone = transportFor('phone');
      final laptop = transportFor('laptop');
      final first = _change('phone', 0);
      final late = _change('phone', 1);
      final third = _change('phone', 2);
      await phone.push([first]);
      await phone.push([late]);
      await phone.push([third]);
      drive.hidden.add('changes/phone/0000000002.json');

      final batches = await laptop.pull().toList();
      expect(batches.expand((batch) => batch.changes), [first]);

      drive.hidden.clear();
      expect(await _pulled(laptop, since: batches.last.cursor), [late, third]);
    });

    test('only lists files created since the last pull', () async {
      final phone = transportFor('phone');
      final laptop = transportFor('laptop');
      await phone.push([_change('phone', 0)]);
      final cursor = (await laptop.pull().toList()).last.cursor;

      await phone.push([_change('phone', 1)]);
      final after = await _pulled(laptop, since: cursor);

      expect(after, [_change('phone', 1)]);
    });

    test('updates latest.json in place for each snapshot', () async {
      final phone = transportFor('phone');
      for (final millis in [1000, 2000]) {
        await phone.writeSnapshot(
          Snapshot(changes: const [], through: Hlc(millis, 0, 'phone')),
        );
      }

      expect(
        drive.files.where((file) => file.name == 'latest.json'),
        hasLength(1),
      );
      expect(
        drive.files.where((file) => file.name.startsWith('snapshots/')),
        hasLength(2),
      );
    });

    test('backs off and retries while Drive is rate limiting', () async {
      final phone = transportFor('phone');
      drive.rateLimitedCalls = 3;

      await phone.push([_change('phone', 0)]);

      expect(waits, const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 4),
      ]);
      expect(drive.files, hasLength(1));
    });

    test('gives up after the last attempt', () async {
      final phone = transportFor('phone', maxAttempts: 2);
      drive.rateLimitedCalls = 2;

      await expectLater(
        phone.push([_change('phone', 0)]),
        throwsA(isA<DriveRateLimited>()),
      );
      expect(waits, const [Duration(seconds: 1)]);
    });

    test('ignores files it did not write', () async {
      await FakeDriveAppFolder(drive).create('notes.txt', Uint8List(0));

      expect(await _pulled(transportFor('phone')), isEmpty);
    });

    test('rate limits print a readable error', () {
      expect(const DriveRateLimited().toString(), 'DriveRateLimited');
    });
  });
}
