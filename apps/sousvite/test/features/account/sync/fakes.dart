import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/services/error_reporter.dart';
import 'package:sousvite/features/account/sync/application/sync_transport.dart';
import 'package:sousvite/features/account/sync/data/drive_access.dart';
import 'package:sync/sync.dart';

/// Records reported errors instead of sending them.
class RecordingReporter() implements ErrorReporter {
  final errors = <Object>[];

  @override
  Future<void> report(Object error, StackTrace stackTrace) async =>
      errors.add(error);
}

/// Drive access with a fixed token, counting requests.
class FakeDriveAccess() implements DriveAccess {
  int requests = 0;
  final discarded = <String>[];

  /// Thrown by [token] when set.
  Exception? tokenError;

  /// The token [token] returns.
  String current = 't1';

  @override
  Future<String> token() async {
    if (tokenError case final error?) throw error;
    return current;
  }

  @override
  Future<void> discard(String token) async => discarded.add(token);

  @override
  Future<void> request() async => requests++;
}

/// A transport whose calls all fail with [error].
class FailingTransport(final Exception error) implements SyncTransport {
  @override
  Future<void> push(List<Change> changes) async => throw error;

  @override
  Stream<PulledBatch> pull({SyncCursor? since}) => Stream.error(error);

  @override
  Future<void> writeSnapshot(Snapshot snapshot) async => throw error;
}

/// A working transport whose snapshot writes fail with [snapshotError]
/// while it is set.
class SnapshotFailingTransport(final SyncTransport _inner)
    implements SyncTransport {
  /// Thrown by [writeSnapshot] when set.
  Exception? snapshotError;

  @override
  Future<void> push(List<Change> changes) => _inner.push(changes);

  @override
  Stream<PulledBatch> pull({SyncCursor? since}) => _inner.pull(since: since);

  @override
  Future<void> writeSnapshot(Snapshot snapshot) async {
    if (snapshotError case final error?) throw error;
    await _inner.writeSnapshot(snapshot);
  }
}

/// A Firebase app that is only ever compared with null.
class FakeFirebaseApp() extends Fake implements FirebaseApp;

/// A cloud space that is only ever handed to a transport.
class FakeCloudSpace() extends Fake implements FirestoreSpace;

/// A bucket that is only ever handed to a photo store.
class FakeCloudFiles() extends Fake implements CloudFiles;

/// Makes [FakeCloudSpace]s.
FirestoreSpace fakeCloudSpaces({
  required String uid,
  required String spaceId,
}) => FakeCloudSpace();

/// Sousvite cloud made of fakes.
final CloudBackend fakeCloud = (
  spaces: fakeCloudSpaces,
  files: FakeCloudFiles(),
);
