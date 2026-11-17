import 'dart:async';

import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/services/sharing_service.dart';
import 'package:sousvite/features/sharing/application/recipe_sharing.dart';

part 'share_links.g.dart';

/// The copy invite link made for [recipeId] on the share screen: null until
/// made, loading while it's made, or the error.
@riverpod
class CopyLink() extends _$CopyLink {
  @override
  FutureOr<Uri?> build(RecipeId recipeId) => null;

  /// Makes a new copy link.
  Future<void> create() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(recipeSharingProvider).sendCopy(recipeId),
    );
    if (ref.mounted) state = result;
  }
}

/// The view-only link id published for [recipeId] on the share screen, null
/// until published or after it's turned off.
@riverpod
class ViewOnlyLink() extends _$ViewOnlyLink {
  @override
  FutureOr<String?> build(RecipeId recipeId) => null;

  /// Publishes the recipe. [yieldText] says how many it serves.
  Future<void> publish({required String? Function(Recipe recipe) yieldText}) =>
      _run(
        () => ref
            .read(recipeSharingProvider)
            .publishLink(recipeId, yieldText: yieldText),
      );

  /// Turns the published link off.
  Future<void> turnOff() async {
    final linkId = state.value;
    if (linkId == null) return;
    await _run(() async {
      await ref.read(recipeSharingProvider).unpublishLink(linkId);
      return null;
    });
  }

  Future<void> _run(Future<String?> Function() action) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(action);
    if (ref.mounted) state = result;
  }
}

/// The page address of a view-only link id.
Uri viewOnlyLinkUrl(String linkId) => SharingLinks.page(linkId);
