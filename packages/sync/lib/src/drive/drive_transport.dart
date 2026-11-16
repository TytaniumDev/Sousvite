import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:sync/src/core/change.dart';
import 'package:sync/src/drive/drive_app_folder.dart';
import 'package:sync/src/transport/snapshot_codec.dart';
import 'package:sync/src/transport/sync_transport.dart';

/// Syncs the user's library through their own Google Drive, in the hidden
/// app folder (ENGINEERING.md §8.2).
///
/// Each push is one file, `changes/{deviceId}/{seq}.json`, and files are
/// never deleted, so the folder is a full backup. Snapshots are
/// `snapshots/{hlc}.json.gz`, and `latest.json` names the newest.
///
/// Drive has no change feed for a fresh device, so a pull lists the files
/// created since the last pull (less [listingMargin], in case Drive lists
/// a new file late) and reads each device's files in sequence. A device's
/// file that is missing from a listing stops that device there, so a late
/// file is read next time instead of skipped. The cursor holds the next
/// sequence number for each device and the listing time.
final class DriveTransport(
  /// The user's app folder.
  final DriveAppFolder folder, {

  /// This device's id, which names its change files.
  required final String deviceId,

  /// How far back each listing reaches before the last one, for files
  /// Drive lists late.
  final Duration listingMargin = const Duration(minutes: 10),

  /// How many times a rate-limited call is tried before giving up.
  final int maxAttempts = 6,

  /// Waits between rate-limited attempts. Tests pass one that returns at
  /// once.
  final Future<void> Function(Duration) wait = _wait,
}) implements SyncTransport {
  int? _nextSeq;

  @override
  Future<void> push(List<Change> changes) async {
    if (changes.isEmpty) return;
    final seq = _nextSeq ??= await _findNextOwnSeq();
    await _retry(
      () => folder.create(
        _changeFileName(deviceId, seq),
        _encodeChanges(changes),
      ),
    );
    _nextSeq = seq + 1;
  }

  Future<int> _findNextOwnSeq() async {
    final own = (await _retry(folder.list))
        .map(_ChangeFile.parse)
        .whereType<_ChangeFile>()
        .where((file) => file.deviceId == deviceId);
    return own.isEmpty ? 1 : own.map((file) => file.seq).reduce(max) + 1;
  }

  @override
  Stream<PulledBatch> pull({SyncCursor? since}) async* {
    var cursor = _DriveCursor.decode(since);
    if (since == null) {
      final latest = await _readLatest();
      if (latest != null) {
        cursor = _DriveCursor.decode(latest.pulledThrough);
        yield (changes: latest.changes, cursor: cursor.encode());
      }
    }
    final listed = await _retry(
      () => folder.list(createdAfter: cursor.listedAt?.subtract(listingMargin)),
    );
    final files = listed.map(_ChangeFile.parse).whereType<_ChangeFile>();
    final next = Map.of(cursor.nextSeq);
    final ready = <_ChangeFile>[];
    DateTime? firstMissing;
    for (final MapEntry(key: device, value: deviceFiles) in groupBy(
      files,
      (file) => file.deviceId,
    ).entries) {
      final bySeq = {for (final file in deviceFiles) file.seq: file};
      var seq = next[device] ?? 1;
      for (
        var file = bySeq.remove(seq);
        file != null;
        file = bySeq.remove(seq)
      ) {
        ready.add(file);
        seq++;
      }
      // Files after a gap wait until the missing one is listed.
      for (final later in bySeq.values.where((file) => file.seq > seq)) {
        if (firstMissing == null || later.createdTime.isBefore(firstMissing)) {
          firstMissing = later.createdTime;
        }
      }
    }
    ready.sort(
      (a, b) => a.createdTime != b.createdTime
          ? a.createdTime.compareTo(b.createdTime)
          : a.name.compareTo(b.name),
    );
    for (final (index, file) in ready.indexed) {
      final changes = _decodeChanges(await _retry(() => folder.read(file.id)));
      next[file.deviceId] = file.seq + 1;
      final isLast = index == ready.length - 1;
      yield (
        changes: changes,
        cursor: _DriveCursor(
          nextSeq: next,
          listedAt: isLast
              ? _listedThrough(cursor.listedAt, file.createdTime, firstMissing)
              : cursor.listedAt,
        ).encode(),
      );
    }
  }

  /// The listing time a finished pull can move to: the newest file read,
  /// but never past a file still waiting on a gap.
  static DateTime? _listedThrough(
    DateTime? before,
    DateTime newest,
    DateTime? firstMissing,
  ) {
    var through = newest;
    if (firstMissing != null && firstMissing.isBefore(through)) {
      through = firstMissing;
    }
    return before != null && before.isAfter(through) ? before : through;
  }

  @override
  Future<void> writeSnapshot(Snapshot snapshot) async {
    final hlc = snapshot.through.pack();
    final file = await _retry(
      () => folder.create('snapshots/$hlc.json.gz', encodeSnapshot(snapshot)),
    );
    final pointer = Uint8List.fromList(
      utf8.encode(jsonEncode({'id': file.id, 'name': file.name, 'hlc': hlc})),
    );
    final latest = await _retry(() => folder.find(_latestName));
    if (latest == null) {
      await _retry(() => folder.create(_latestName, pointer));
    } else {
      await _retry(() => folder.update(latest.id, pointer));
    }
  }

  Future<Snapshot?> _readLatest() async {
    final latest = await _retry(() => folder.find(_latestName));
    if (latest == null) return null;
    final pointer = jsonDecode(
      utf8.decode(await _retry(() => folder.read(latest.id))),
    ) as Map<String, Object?>;
    return decodeSnapshot(
      await _retry(() => folder.read(pointer['id']! as String)),
    );
  }

  /// Runs [call], waiting and trying again with exponential backoff while
  /// Drive is rate limiting.
  Future<T> _retry<T>(Future<T> Function() call) async {
    for (var attempt = 1; ; attempt++) {
      try {
        return await call();
      } on DriveRateLimited {
        if (attempt >= maxAttempts) rethrow;
        await wait(Duration(seconds: 1 << (attempt - 1)));
      }
    }
  }

  static const _latestName = 'latest.json';

  static String _changeFileName(String deviceId, int seq) =>
      'changes/$deviceId/${seq.toString().padLeft(10, '0')}.json';

  static Uint8List _encodeChanges(List<Change> changes) => Uint8List.fromList(
    utf8.encode(jsonEncode([for (final change in changes) change.toJson()])),
  );

  static List<Change> _decodeChanges(Uint8List bytes) => [
    for (final json in jsonDecode(utf8.decode(bytes)) as List<Object?>)
      Change.fromJson(json! as Map<String, Object?>),
  ];

  static Future<void> _wait(Duration duration) =>
      Future<void>.delayed(duration);
}

/// A change file's place in its device's sequence.
final class _ChangeFile({
  required final String id,
  required final String name,
  required final String deviceId,
  required final int seq,
  required final DateTime createdTime,
}) {
  /// [file] as a change file, or null when it is some other file.
  static _ChangeFile? parse(DriveFile file) {
    final match = _pattern.firstMatch(file.name);
    if (match == null) return null;
    return _ChangeFile(
      id: file.id,
      name: file.name,
      deviceId: match.group(1)!,
      seq: int.parse(match.group(2)!),
      createdTime: file.createdTime,
    );
  }

  static final _pattern = RegExp(r'^changes/(.+)/(\d+)\.json$');
}

/// Where a Drive pull left off: the next sequence number to read from each
/// device, and the time of the last listing.
final class _DriveCursor({
  required final Map<String, int> nextSeq,
  final DateTime? listedAt,
}) {
  factory decode(SyncCursor? cursor) {
    final value = cursor?.value;
    if (value == null || value.isEmpty) return _DriveCursor(nextSeq: const {});
    final json = jsonDecode(value) as Map<String, Object?>;
    final listedAt = json['t'] as int?;
    return _DriveCursor(
      nextSeq: (json['s']! as Map<String, Object?>).cast<String, int>(),
      listedAt: listedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(listedAt, isUtc: true),
    );
  }

  SyncCursor encode() => SyncCursor(
    jsonEncode({'s': nextSeq, 't': listedAt?.millisecondsSinceEpoch}),
  );
}
