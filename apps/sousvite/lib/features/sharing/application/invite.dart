import 'dart:async';

import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/services/sharing_service.dart';
import 'package:sousvite/features/sharing/application/recipe_sharing.dart';

part 'invite.g.dart';

/// What the invite [inviteId] offers. Not retried: an expired or missing
/// invite stays that way, and the screen says so at once.
@Riverpod(retry: _noRetry)
Future<InvitePreview> invitePreview(Ref ref, String inviteId) =>
    ref.watch(recipeSharingProvider).previewInvite(inviteId);

/// Accepts the invite [inviteId]: loading while it runs, then the saved
/// copy's id (null before accepting or for a joint share), or the error.
@riverpod
class InviteAcceptance() extends _$InviteAcceptance {
  @override
  FutureOr<RecipeId?> build(String inviteId) => null;

  /// Accepts and returns the saved copy's id, or null when it failed.
  Future<RecipeId?> accept() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(recipeSharingProvider).accept(inviteId),
    );
    if (ref.mounted) state = result;
    return result.value;
  }
}

Duration? _noRetry(int retryCount, Object error) => null;
