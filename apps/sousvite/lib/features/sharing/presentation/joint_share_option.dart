import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/sharing/application/recipe_sharing.dart';
import 'package:sousvite/features/sharing/application/share_links.dart';
import 'package:sousvite/features/sharing/presentation/share_link_row.dart';
import 'package:sousvite/features/sharing/presentation/share_option_card.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Share together: an invite link to edit the recipe jointly, and leaving
/// once it's shared (PRD 7.10).
class const JointShareOption({required final RecipeId recipeId, super.key})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final shared = ref.watch(
      recipeSharedSpaceProvider(recipeId)
          .select((space) => space.value != null),
    );
    return ShareOptionCard(
      icon: Symbols.group_rounded,
      title: l10n.sharing_jointTitle,
      body: shared ? l10n.sharing_jointSharedBody : l10n.sharing_jointBody,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          _InviteLink(recipeId: recipeId),
          if (shared) ...[
            const SizedBox(height: AppSpacing.space2),
            _LeaveButton(recipeId: recipeId),
          ],
        ],
      ),
    );
  }
}

/// The button that makes an invite link, then the link.
class const _InviteLink({required final RecipeId recipeId})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final link = ref.watch(jointLinkProvider(recipeId));
    final made = link.value;
    if (made == null) {
      return FilledButton(
        onPressed: link.isLoading
            ? null
            : () => ref.read(jointLinkProvider(recipeId).notifier).create(),
        child: Text(l10n.sharing_jointCreate),
      );
    }
    return Column(
      crossAxisAlignment: .start,
      children: [
        ShareLinkRow(link: made),
        const SizedBox(height: AppSpacing.space2),
        Text(
          l10n.sharing_jointExpiry,
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Leaves the share after the user confirms.
class const _LeaveButton({required final RecipeId recipeId})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final busy = ref.watch(
      jointLinkProvider(recipeId).select((link) => link.isLoading),
    );
    return TextButton.icon(
      icon: const Icon(Symbols.logout_rounded),
      label: Text(l10n.sharing_jointLeave),
      onPressed: busy
          ? null
          : () async {
              final leave = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.sharing_jointLeaveTitle),
                  content: Text(l10n.sharing_jointLeaveBody),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        MaterialLocalizations.of(context).cancelButtonLabel,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l10n.sharing_jointLeaveConfirm),
                    ),
                  ],
                ),
              );
              if (!(leave ?? false)) return;
              final notifier = ref.read(jointLinkProvider(recipeId).notifier);
              await notifier.leave();
              if (!context.mounted) return;
              if (ref.read(jointLinkProvider(recipeId)).hasError) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.sharing_jointLeft)));
            },
    );
  }
}
