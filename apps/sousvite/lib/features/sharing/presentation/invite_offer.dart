import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/services/sharing_service.dart';
import 'package:sousvite/features/recipe/recipe.dart';
import 'package:sousvite/features/sharing/application/invite.dart';
import 'package:sousvite/features/sharing/presentation/invite_screen.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/widgets/async_value_view.dart';

/// What an invite offers, so the recipient knows whether it's a copy or a
/// joint share before accepting (PRD 7.10), and the button to accept.
class const InviteOffer({required final String inviteId, super.key})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(invitePreviewProvider(inviteId)),
    error: (_, _) => const InviteGone(),
    data: (preview) => switch (preview.kind) {
      .copy => _CopyOffer(inviteId: inviteId, preview: preview),
      .joint => _JointOffer(preview: preview),
    },
  );
}

class const _CopyOffer({
  required final String inviteId,
  required final InvitePreview preview,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final busy = ref.watch(
      inviteAcceptanceProvider(inviteId).select((state) => state.isLoading),
    );
    final from = preview.fromName;
    return EmptyState(
      icon: Symbols.content_copy_rounded,
      title: from == null
          ? l10n.sharing_inviteCopy(preview.title)
          : l10n.sharing_inviteCopyFrom(from, preview.title),
      message: l10n.sharing_inviteCopyBody,
      action: FilledButton(
        onPressed: busy
            ? null
            : () async {
                final recipeId = await ref
                    .read(inviteAcceptanceProvider(inviteId).notifier)
                    .accept();
                if (!context.mounted) return;
                final messenger = ScaffoldMessenger.of(context);
                if (recipeId == null) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.sharing_failed)),
                  );
                  return;
                }
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.sharing_inviteAdded)),
                );
                context.go(RecipeRoutes.location(recipeId));
              },
        child: Text(l10n.sharing_inviteAccept),
      ),
    );
  }
}

class const _JointOffer({required final InvitePreview preview})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final from = preview.fromName;
    return EmptyState(
      icon: Symbols.group_rounded,
      title: from == null
          ? l10n.sharing_inviteJoint(preview.title)
          : l10n.sharing_inviteJointFrom(from, preview.title),
      message: l10n.sharing_inviteJointBody,
    );
  }
}
