import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/sharing/application/share_links.dart';
import 'package:sousvite/features/sharing/presentation/share_link_row.dart';
import 'package:sousvite/features/sharing/presentation/share_option_card.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Link for anyone: publishes a read-only page of the recipe, and turns it
/// off again (PRD 7.10).
class const ViewOnlyLinkOption({required final RecipeId recipeId, super.key})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final link = ref.watch(viewOnlyLinkProvider(recipeId));
    final notifier = ref.read(viewOnlyLinkProvider(recipeId).notifier);
    final linkId = link.value;
    return ShareOptionCard(
      icon: Symbols.public_rounded,
      title: l10n.sharing_linkTitle,
      body: l10n.sharing_linkBody,
      child: linkId == null
          ? FilledButton(
              onPressed: link.isLoading
                  ? null
                  : () => notifier.publish(
                      yieldText: (recipe) => AmountText.textFor(
                        recipe.servings,
                        l10n.recipe_servings(
                          recipe.servings == Quantity(1) ? 1 : 2,
                        ),
                      ),
                    ),
              child: Text(l10n.sharing_linkCreate),
            )
          : Column(
              crossAxisAlignment: .start,
              children: [
                ShareLinkRow(link: viewOnlyLinkUrl(linkId)),
                const SizedBox(height: AppSpacing.space2),
                TextButton(
                  onPressed: link.isLoading
                      ? null
                      : () async {
                          await notifier.turnOff();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.sharing_linkTurnedOff)),
                          );
                        },
                  child: Text(l10n.sharing_linkTurnOff),
                ),
              ],
            ),
    );
  }
}
