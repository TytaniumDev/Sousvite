import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/sharing/application/share_links.dart';
import 'package:sousvite/features/sharing/presentation/share_link_row.dart';
import 'package:sousvite/features/sharing/presentation/share_option_card.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Send a copy: makes an invite link that gives each person who opens it
/// their own copy (PRD 7.10).
class const CopyLinkOption({required final RecipeId recipeId, super.key})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final link = ref.watch(copyLinkProvider(recipeId));
    final made = link.value;
    return ShareOptionCard(
      icon: Symbols.content_copy_rounded,
      title: l10n.sharing_copyTitle,
      body: l10n.sharing_copyBody,
      child: made == null
          ? FilledButton(
              onPressed: link.isLoading
                  ? null
                  : () =>
                        ref.read(copyLinkProvider(recipeId).notifier).create(),
              child: Text(l10n.sharing_copyCreate),
            )
          : Column(
              crossAxisAlignment: .start,
              children: [
                ShareLinkRow(link: made),
                const SizedBox(height: AppSpacing.space2),
                Text(
                  l10n.sharing_copyExpiry,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
    );
  }
}
