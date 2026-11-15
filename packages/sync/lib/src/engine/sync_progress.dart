import 'package:meta/meta.dart';
import 'package:sync/src/core/hlc.dart';
import 'package:sync/src/transport/sync_transport.dart';

/// How far one transport has synced one space.
@immutable
final class const SyncProgress({
  /// Where the last pull left off, or null before the first pull.
  final SyncCursor? pullCursor,

  /// The HLC of the last local change pushed, or null before the first
  /// push.
  final Hlc? pushedThrough,
}) {
  /// A copy with the given fields replaced.
  SyncProgress copyWith({SyncCursor? pullCursor, Hlc? pushedThrough}) =>
      SyncProgress(
        pullCursor: pullCursor ?? this.pullCursor,
        pushedThrough: pushedThrough ?? this.pushedThrough,
      );

  @override
  bool operator ==(Object other) =>
      other is SyncProgress &&
      other.pullCursor == pullCursor &&
      other.pushedThrough == pushedThrough;

  @override
  int get hashCode => Object.hash(pullCursor, pushedThrough);
}
