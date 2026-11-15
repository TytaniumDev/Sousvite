import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/library/application/library_filter.dart';
import 'package:sousvite/features/library/application/library_recipes.dart';
import 'package:sousvite/features/library/presentation/library_recipe_card.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/widgets/async_value_view.dart';

/// The recipes the library shows, as cards in rows.
///
/// Rows are laid out by hand rather than with a fixed-ratio grid, so a
/// card is as tall as its name and badges need at any text size. The grid
/// rebuilds only when the list of ids changes; each card watches its own
/// recipe.
class const RecipeGrid({super.key}) extends ConsumerWidget {
  /// The narrowest a card gets before the grid drops a column.
  static const double minCardWidth = 168;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(visibleRecipeIdsProvider),
    error: (_, _) => ErrorState(
      title: context.l10n.library_loadErrorTitle,
      message: context.l10n.library_loadErrorMessage,
      retryLabel: context.l10n.common_retry,
      onRetry: () => ref.invalidate(allRecipeIdsProvider),
    ),
    data: (ids) =>
        ids.isEmpty ? const _EmptyLibrary() : _CardRows(recipeIds: ids),
  );
}

class const _CardRows({required final List<RecipeId> recipeIds})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final available = constraints.maxWidth - 2 * AppSpacing.space4;
      final columns = math.max(
        1,
        (available + AppSpacing.space3) ~/
            (RecipeGrid.minCardWidth + AppSpacing.space3),
      );
      final rowCount = (recipeIds.length / columns).ceil();
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space4,
          AppSpacing.space2,
          AppSpacing.space4,
          // Room for the floating button over the last row.
          AppSpacing.space16 + AppSpacing.space6,
        ),
        itemCount: rowCount,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.space3),
        itemBuilder: (context, row) {
          final start = row * columns;
          final rowIds = recipeIds.sublist(
            start,
            math.min(start + columns, recipeIds.length),
          );
          return Row(
            crossAxisAlignment: .start,
            spacing: AppSpacing.space3,
            children: [
              for (final id in rowIds)
                Expanded(
                  child: LibraryRecipeCard(key: ValueKey(id), recipeId: id),
                ),
              // Keeps cards in a short last row the same width as above.
              for (var i = rowIds.length; i < columns; i++)
                const Expanded(child: SizedBox.shrink()),
            ],
          );
        },
      );
    },
  );
}

/// Says why the grid is empty: no recipes at all, an empty folder, or a
/// search with no matches.
class const _EmptyLibrary() extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final searching = ref.watch(
      libraryQueryProvider.select((query) => query.trim().isNotEmpty),
    );
    final inFolder = ref.watch(
      libraryFolderProvider.select((folder) => folder != null),
    );
    if (searching) {
      return EmptyState(
        icon: Symbols.search_off_rounded,
        title: l10n.library_noMatchesTitle,
        message: l10n.library_noMatchesMessage,
      );
    }
    if (inFolder) {
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
