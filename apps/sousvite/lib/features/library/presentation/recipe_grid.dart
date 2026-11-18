import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/library/application/library_filter.dart';
import 'package:sousvite/features/library/application/library_recipes.dart';
import 'package:sousvite/features/library/application/library_scope.dart';
import 'package:sousvite/features/library/presentation/library_recipe_card.dart';
import 'package:sousvite/features/library/presentation/sliver_card_rows.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/widgets/async_value_view.dart';

/// The recipes a page shows, as cards in rows. A sliver.
///
/// Shows the recipes in [scope], kept to the page's search. The grid
/// rebuilds only when the list of ids changes; each card watches its own
/// recipe.
class const RecipeGrid({
  /// Which recipes this shows.
  required final LibraryScope scope,
  super.key,
}) extends ConsumerWidget {
  /// The narrowest a card gets before the grid drops a column.
  static const double minCardWidth = 168;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(visibleRecipeIdsProvider(scope));
    if (value case AsyncData(value: final ids) when ids.isNotEmpty) {
      return SliverCardRows(
        itemCount: ids.length,
        minItemWidth: minCardWidth,
        itemBuilder: (context, index) =>
            LibraryRecipeCard(key: ValueKey(ids[index]), recipeId: ids[index]),
      );
    }
    return SliverFillRemaining(
      hasScrollBody: false,
      child: AsyncValueView(
        value: value,
        error: (_, _) => ErrorState(
          title: context.l10n.library_loadErrorTitle,
          message: context.l10n.library_loadErrorMessage,
          retryLabel: context.l10n.common_retry,
          onRetry: () => ref.invalidate(allRecipeIdsProvider),
        ),
        data: (_) => _EmptyGrid(scope: scope),
      ),
    );
  }
}

/// Says why the grid is empty: no recipes at all, an empty folder, or a
/// search with no matches.
class const _EmptyGrid({required final LibraryScope scope})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (ref.watch(isSearchingProvider(scope))) {
      return EmptyState(
        icon: Symbols.search_off_rounded,
        title: l10n.library_noMatchesTitle,
        message: l10n.library_noMatchesMessage,
      );
    }
    if (scope is! AllRecipes) {
      return EmptyState(
        icon: Symbols.folder_open_rounded,
        title: l10n.library_emptyFolderTitle,
        message: l10n.library_emptyFolderMessage,
      );
    }
    return EmptyState(
      icon: Symbols.menu_book_rounded,
      title: l10n.library_emptyTitle,
      message: l10n.library_emptyMessage,
    );
  }
}

/// Room under the last row, so the floating button never covers it.
class const RecipeGridEndSpace({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SliverToBoxAdapter(
    child: SizedBox(height: AppSpacing.space16 + AppSpacing.space6),
  );
}
