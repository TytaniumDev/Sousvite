import 'package:cloud_functions/cloud_functions.dart';
import 'package:sousvite/app/services/sharing_service.dart';

/// [SharingService] through the sharing Cloud Functions in
/// `functions/src/sharing/`.
class const FirebaseSharingService(final FirebaseFunctions _functions)
    implements SharingService {
  @override
  Future<({String spaceId, Uri invite})> shareJointly({
    required String name,
    String? spaceId,
  }) async {
    final result = await _call('shareJointly', {
      'name': name,
      'spaceId': ?spaceId,
    });
    return (
      spaceId: result['spaceId']! as String,
      invite: SharingLinks.invite(result['inviteId']! as String),
    );
  }

  @override
  Future<Uri> sendCopy({
    required String title,
    required List<Map<String, Object?>> entities,
  }) async {
    final result = await _call('sendCopy', {
      'title': title,
      'entities': entities,
    });
    return SharingLinks.invite(result['inviteId']! as String);
  }

  @override
  Future<InvitePreview> previewInvite(String inviteId) async {
    final result = await _call('previewInvite', {'inviteId': inviteId});
    return InvitePreview(
      kind: InviteKind.values.byName(result['kind']! as String),
      title: result['title']! as String,
      fromName: result['fromName'] as String?,
    );
  }

  @override
  Future<AcceptedInvite> acceptInvite(String inviteId) async {
    final result = await _call('acceptInvite', {'inviteId': inviteId});
    final title = result['title']! as String;
    return switch (result['kind']) {
      'joint' => AcceptedJointShare(
        spaceId: result['spaceId']! as String,
        title: title,
      ),
      _ => AcceptedCopy(
        title: title,
        entities: result['entities']! as List<Object?>,
      ),
    };
  }

  @override
  Future<void> leaveShare(String spaceId) =>
      _call('leaveShare', {'spaceId': spaceId});

  @override
  Future<String> publishLink(SharedRecipePage page, {String? linkId}) async {
    final result = await _call('publishLink', {
      'recipe': page.toJson(),
      'linkId': ?linkId,
    });
    return result['linkId']! as String;
  }

  @override
  Future<void> unpublishLink(String linkId) =>
      _call('unpublishLink', {'linkId': linkId});

  /// Calls [name] with [data] and returns its result map, turning failures
  /// into [SharingFailure].
  Future<Map<Object?, Object?>> _call(
    String name,
    Map<String, Object?> data,
  ) async {
    try {
      final result = await _functions
          .httpsCallable(name)
          .call<Map<Object?, Object?>>(data);
      return result.data;
    } on FirebaseFunctionsException catch (error) {
      throw SharingFailure(_reasonFor(error), error);
    }
  }

  static SharingFailureReason _reasonFor(FirebaseFunctionsException error) {
    final details = error.details;
    final reason = details is Map ? details['reason'] : null;
    return switch ((error.code, reason)) {
      ('unauthenticated', _) => .signedOut,
      (_, 'expired') => .expired,
      (_, 'shareEnded') => .shareEnded,
      (_, 'proRequired') => .proRequired,
      (_, 'tooLarge') => .tooLarge,
      ('not-found', _) => .notFound,
      _ => .unavailable,
    };
  }
}
