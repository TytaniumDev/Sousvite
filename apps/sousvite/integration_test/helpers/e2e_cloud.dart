import 'dart:async';

import 'package:collection/collection.dart';
import 'package:sousvite/app/services/auth_service.dart';
import 'package:sousvite/app/services/sharing_service.dart';
import 'package:sync/sync.dart';

/// The server, in memory: each user's own library, each joint share, and
/// the sharing functions. Every device in a test talks to one of these.
class E2eCloud() {
  final _spaces = <String, InMemorySyncSpace>{};
  final _photos = <String, InMemoryBlobStore>{};
  final _members = <String, Set<String>>{};
  final _titles = <String, String>{};
  final _invites = <String, String>{};
  final _membershipChanges = StreamController<void>.broadcast();
  var _ids = 0;

  String _newId(String prefix) => '$prefix${_ids++}';

  /// The id of the last invite link made, as the person sharing it would
  /// send it.
  String? get lastInviteId => _invites.keys.lastOrNull;

  /// The space with the server id [id], made when first asked for.
  InMemorySyncSpace space(String id) =>
      _spaces.putIfAbsent(id, InMemorySyncSpace.new);

  /// The photo files of the space with the server id [id].
  BlobStore photos(String id) => _photos.putIfAbsent(id, InMemoryBlobStore.new);

  /// [uid]'s own library.
  InMemorySyncSpace privateSpace(String uid) => space('u_$uid');

  /// The joint shares [uid] is in, sorted, and again on each change.
  Stream<List<String>> sharedSpaceIdsOf(String uid) {
    List<String> ids() => [
      for (final MapEntry(:key, :value) in _members.entries)
        if (value.contains(uid)) key,
    ]..sort();
    StreamSubscription<void>? changes;
    late final StreamController<List<String>> controller;
    controller = StreamController(
      onListen: () {
        controller.add(ids());
        changes = _membershipChanges.stream.listen(
          (_) => controller.add(ids()),
        );
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream.distinct(const ListEquality<String>().equals);
  }

  /// The sharing functions, called as [user].
  SharingService sharingFor(AuthUser user) => _E2eSharing(this, user);
}

class _E2eSharing(final E2eCloud _cloud, final AuthUser _user)
    implements SharingService {
  @override
  Future<({String spaceId, Uri invite})> shareJointly({
    required String name,
    String? spaceId,
  }) async {
    final id = spaceId ?? _cloud._newId('s_');
    _cloud._members.putIfAbsent(id, () => {}).add(_user.id);
    _cloud._titles.putIfAbsent(id, () => name);
    final inviteId = _cloud._newId('invite');
    _cloud._invites[inviteId] = id;
    _cloud._membershipChanges.add(null);
    return (spaceId: id, invite: SharingLinks.invite(inviteId));
  }

  @override
  Future<InvitePreview> previewInvite(String inviteId) async {
    final spaceId = _spaceOf(inviteId);
    return InvitePreview(
      kind: .joint,
      title: _cloud._titles[spaceId]!,
      fromName: 'Alice',
    );
  }

  @override
  Future<AcceptedInvite> acceptInvite(String inviteId) async {
    final spaceId = _spaceOf(inviteId);
    _cloud._members[spaceId]!.add(_user.id);
    _cloud._membershipChanges.add(null);
    return AcceptedJointShare(
      spaceId: spaceId,
      title: _cloud._titles[spaceId]!,
    );
  }

  @override
  Future<void> leaveShare(String spaceId) async {
    _cloud._members[spaceId]?.remove(_user.id);
    _cloud._membershipChanges.add(null);
  }

  String _spaceOf(String inviteId) =>
      _cloud._invites[inviteId] ?? (throw const SharingFailure(.notFound));

  @override
  Future<Uri> sendCopy({
    required String title,
    required List<Map<String, Object?>> entities,
  }) => throw UnimplementedError('Not used in the end-to-end flows.');

  @override
  Future<String> publishLink(SharedRecipePage page, {String? linkId}) =>
      throw UnimplementedError('Not used in the end-to-end flows.');

  @override
  Future<void> unpublishLink(String linkId) =>
      throw UnimplementedError('Not used in the end-to-end flows.');
}
