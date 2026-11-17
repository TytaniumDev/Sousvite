import 'package:clock/clock.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/app/services/sharing_service.dart';
import 'package:sousvite/features/sharing/application/shared_recipe_page.dart';
import 'package:uuid/uuid.dart';

part 'recipe_sharing.g.dart';

@riverpod
RecipeSharing recipeSharing(Ref ref) => RecipeSharing(
  repository: ref.watch(recipeRepositoryProvider),
  spaces: ref.watch(recipeSpaceRepositoryProvider),
  service: ref.watch(sharingServiceProvider),
);

/// The joint share [recipeId] is in, or null when it's only the user's.
@riverpod
Stream<String?> recipeSharedSpace(Ref ref, RecipeId recipeId) =>
    ref.watch(recipeSpaceRepositoryProvider).watchSharedSpace(recipeId);

/// Shares recipes jointly, sends copies, publishes view-only links, and
/// saves copies other people sent (PRD 7.10).
class const RecipeSharing({
  required final RecipeRepository _repository,
  required final RecipeSpaceRepository _spaces,
  required final SharingService _service,
}) {
  static const _codec = RecipeSnapshotCodec();

  /// An invite link for editing [recipeId] together. The first time, this
  /// starts a joint share and moves the recipe into it, so everyone who
  /// joins gets it and every later edit.
  Future<Uri> shareJointly(RecipeId recipeId) async {
    final recipe =
        await _repository.getRecipe(recipeId) ??
        (throw StateError('No recipe $recipeId'));
    final current = await _spaces.sharedSpaceOf(recipeId);
    final share = await _service.shareJointly(
      name: recipe.title,
      spaceId: current,
    );
    if (current == null) {
      await _spaces.moveToSharedSpace(recipeId, share.spaceId);
    }
    return share.invite;
  }

  /// Leaves the joint share [recipeId] is in. The user keeps the share's
  /// recipes as their own, as they are now, and the others keep theirs.
  Future<void> leaveJointShare(RecipeId recipeId) async {
    final spaceId = await _spaces.sharedSpaceOf(recipeId);
    if (spaceId == null) return;
    await _service.leaveShare(spaceId);
    for (final id in await _spaces.recipesInSharedSpace(spaceId)) {
      await _spaces.moveToOwnLibrary(id);
    }
  }

  /// An invite link that gives each person who opens it a copy of
  /// [recipeId].
  Future<Uri> sendCopy(RecipeId recipeId) => _snapshot(recipeId).then(
    (snapshot) => _service.sendCopy(
      title: snapshot.recipe.title,
      entities: _codec.encode(snapshot),
    ),
  );

  /// Publishes [recipeId] at a view-only link anyone can open. Returns the
  /// link id.
  Future<String> publishLink(
    RecipeId recipeId, {
    required String? Function(Recipe recipe) yieldText,
  }) => _snapshot(recipeId).then(
    (snapshot) => _service.publishLink(
      sharedRecipePage(snapshot, yieldText: yieldText(snapshot.recipe)),
    ),
  );

  /// Turns off the view-only link [linkId].
  Future<void> unpublishLink(String linkId) => _service.unpublishLink(linkId);

  /// What the invite [inviteId] offers.
  Future<InvitePreview> previewInvite(String inviteId) =>
      _service.previewInvite(inviteId);

  /// Accepts an invite. A copy is saved, with new ids, as the user's own
  /// recipe, and its id returned. A joint share returns null: the user is
  /// now a member, and its recipes arrive when the share syncs.
  Future<RecipeId?> accept(String inviteId) async {
    final accepted = await _service.acceptInvite(inviteId);
    switch (accepted) {
      case AcceptedJointShare():
        return null;
      case AcceptedCopy(:final entities):
        final source = _codec.decode(entities);
        if (source == null) {
          throw const SharingFailure(.notFound);
        }
        final now = clock.now();
        final copy = source.copyAs(
          RecipeId(const Uuid().v4()),
          newId: const Uuid().v4,
        );
        final received = copy.copyWith(
          recipe: copy.recipe.copyWith(createdAt: now, updatedAt: now),
        );
        await _repository.saveSnapshot(received);
        return received.recipe.id;
    }
  }

  Future<RecipeSnapshot> _snapshot(RecipeId recipeId) async =>
      await _repository.getSnapshot(recipeId) ??
      (throw StateError('No recipe $recipeId'));
}
