import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/services/firebase.dart';
import 'package:sousvite/app/services/firebase_sharing_service.dart';

part 'sharing_service.g.dart';

/// What an invite link gives the person who opens it (PRD 7.10).
enum InviteKind() {
  /// They join a joint share: one recipe everyone edits.
  joint,

  /// They get their own independent copy.
  copy,
}

/// What an invite link offers, shown before the recipient accepts.
@immutable
class const InvitePreview({
  required final InviteKind kind,

  /// The recipe or folder name.
  required final String title,

  /// The sharer's name, or null when their sign-in has none.
  final String? fromName,
}) {
  @override
  bool operator ==(Object other) =>
      other is InvitePreview &&
      other.kind == kind &&
      other.title == title &&
      other.fromName == fromName;

  @override
  int get hashCode => Object.hash(kind, title, fromName);
}

/// What accepting an invite gave the recipient.
@immutable
sealed class const AcceptedInvite();

/// The recipient joined the joint share [spaceId].
final class const AcceptedJointShare({
  required final String spaceId,
  required final String title,
}) extends AcceptedInvite {
  @override
  bool operator ==(Object other) =>
      other is AcceptedJointShare &&
      other.spaceId == spaceId &&
      other.title == title;

  @override
  int get hashCode => Object.hash(spaceId, title);
}

/// The recipient got a copy: every entity of the recipe as JSON records, to
/// save with new ids (`RecipeSnapshotCodec` in `package:data`).
final class const AcceptedCopy({
  required final String title,
  required final List<Object?> entities,
}) extends AcceptedInvite;

/// A section of a view-only recipe page: an optional title and its lines.
@immutable
class const SharedSection({
  required final String? title,
  required final List<String> items,
}) {
  Map<String, Object?> toJson() => {'title': title, 'items': items};
}

/// A recipe as plain text, for a view-only link page anyone can open
/// (PRD 7.10).
@immutable
class const SharedRecipePage({
  required final String title,
  required final List<SharedSection> ingredients,
  required final List<SharedSection> steps,
  final String? yieldText,
  final String? sourceName,
  final String? sourceUrl,
}) {
  Map<String, Object?> toJson() => {
    'title': title,
    'yield': yieldText,
    'sourceName': sourceName,
    'sourceUrl': sourceUrl,
    'ingredients': [for (final section in ingredients) section.toJson()],
    'steps': [for (final section in steps) section.toJson()],
  };
}

/// Why a sharing call failed, so the app can say what to do next.
enum SharingFailureReason() {
  /// Sharing needs sign-in.
  signedOut,

  /// The invite or link doesn't exist anymore.
  notFound,

  /// The invite is too old.
  expired,

  /// Everyone left the joint share.
  shareEnded,

  /// Sharing needs Pro (off during the beta).
  proRequired,

  /// The recipe is too large to send.
  tooLarge,

  /// No connection, or sharing isn't set up in this build.
  unavailable,
}

/// A sharing call that failed.
class const SharingFailure(
  final SharingFailureReason reason, [

  /// What went wrong underneath, for error reports.
  final Object? cause,
]) implements Exception {
  @override
  String toString() => 'SharingFailure(${reason.name}): $cause';
}

/// Sharing with other people through the sharing Cloud Functions
/// (ENGINEERING.md §8.4): invite links for joint shares and copies, and
/// view-only links. Every call needs sign-in.
///
/// [FirebaseSharingService] when the build has Firebase config, otherwise
/// [UnavailableSharingService].
abstract interface class SharingService() {
  /// Starts a joint share named [name], or with [spaceId] invites more
  /// people to one. Returns the share's space id and an invite link.
  Future<({String spaceId, Uri invite})> shareJointly({
    required String name,
    String? spaceId,
  });

  /// An invite link that gives each person who opens it a copy of the
  /// recipe [entities] encode.
  Future<Uri> sendCopy({
    required String title,
    required List<Map<String, Object?>> entities,
  });

  /// What the invite [inviteId] offers.
  Future<InvitePreview> previewInvite(String inviteId);

  /// Accepts the invite [inviteId].
  Future<AcceptedInvite> acceptInvite(String inviteId);

  /// Leaves the joint share [spaceId]. The others keep it.
  Future<void> leaveShare(String spaceId);

  /// Publishes [page] at a view-only link, or updates the link [linkId].
  /// Returns the link id.
  Future<String> publishLink(SharedRecipePage page, {String? linkId});

  /// Turns off the view-only link [linkId].
  Future<void> unpublishLink(String linkId);
}

/// Where invite links and view-only pages live: the web app on Hosting.
abstract final class SharingLinks() {
  static final _origin = Uri.https('sousvite.web.app');

  /// The invite link for [inviteId], which the app opens at the sharing
  /// feature's invite route.
  static Uri invite(String inviteId) =>
      _origin.replace(pathSegments: ['invite', inviteId]);

  /// The view-only page for [linkId].
  static Uri page(String linkId) =>
      _origin.replace(pathSegments: ['r', linkId]);
}

/// For builds without Firebase config: every call fails as unavailable.
class const UnavailableSharingService() implements SharingService {
  static Future<Never> _unavailable() =>
      Future.error(const SharingFailure(.unavailable));

  @override
  Future<({String spaceId, Uri invite})> shareJointly({
    required String name,
    String? spaceId,
  }) => _unavailable();

  @override
  Future<Uri> sendCopy({
    required String title,
    required List<Map<String, Object?>> entities,
  }) => _unavailable();

  @override
  Future<InvitePreview> previewInvite(String inviteId) => _unavailable();

  @override
  Future<AcceptedInvite> acceptInvite(String inviteId) => _unavailable();

  @override
  Future<void> leaveShare(String spaceId) => _unavailable();

  @override
  Future<String> publishLink(SharedRecipePage page, {String? linkId}) =>
      _unavailable();

  @override
  Future<void> unpublishLink(String linkId) => _unavailable();
}

@Riverpod(keepAlive: true)
SharingService sharingService(Ref ref) {
  final app = ref.watch(firebaseAppProvider);
  if (app == null) return const UnavailableSharingService();
  return FirebaseSharingService(
    FirebaseFunctions.instanceFor(app: app, region: 'us-central1'),
  );
}
