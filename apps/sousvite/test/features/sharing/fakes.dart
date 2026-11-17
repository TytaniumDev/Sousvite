import 'dart:async';

import 'package:sousvite/app/services/sharing_service.dart';

/// A [SharingService] in memory that records what it was asked.
class FakeSharingService() implements SharingService {
  /// The entities of the last copy sent.
  List<Map<String, Object?>>? sentEntities;

  /// The last page published.
  SharedRecipePage? publishedPage;

  /// Links turned off, in order.
  final unpublished = <String>[];

  /// What [previewInvite] returns.
  InvitePreview preview = const InvitePreview(
    kind: InviteKind.copy,
    title: 'Oat pancakes',
    fromName: 'Alice',
  );

  /// What [acceptInvite] returns.
  AcceptedInvite? accepted;

  /// Thrown by every call, when set.
  Exception? error;

  /// Completes calls when set, so tests can see the busy state.
  Completer<void>? gate;

  Future<void> _act() async {
    await gate?.future;
    if (error case final error?) throw error;
  }

  @override
  Future<({String spaceId, Uri invite})> shareJointly({
    required String name,
    String? spaceId,
  }) async {
    await _act();
    return (spaceId: 's_1', invite: SharingLinks.invite('joint1'));
  }

  @override
  Future<Uri> sendCopy({
    required String title,
    required List<Map<String, Object?>> entities,
  }) async {
    await _act();
    sentEntities = entities;
    return SharingLinks.invite('copy1');
  }

  @override
  Future<InvitePreview> previewInvite(String inviteId) async {
    await _act();
    return preview;
  }

  @override
  Future<AcceptedInvite> acceptInvite(String inviteId) async {
    await _act();
    return accepted!;
  }

  @override
  Future<void> leaveShare(String spaceId) => _act();

  @override
  Future<String> publishLink(SharedRecipePage page, {String? linkId}) async {
    await _act();
    publishedPage = page;
    return 'link1';
  }

  @override
  Future<void> unpublishLink(String linkId) async {
    await _act();
    unpublished.add(linkId);
  }
}
