import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/grocery/application/grocery_entry.dart';
import 'package:sousvite/features/grocery/application/grocery_providers.dart';
import 'package:sousvite/features/grocery/presentation/grocery_entry_row.dart';
import 'package:sousvite/features/grocery/presentation/store_section_name.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/widgets/async_value_view.dart';

/// The list's rows, grouped by store section with sticky headers, then the
/// checked items. Watches only the layout; each row watches its own entry.
class const GroceryListView({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AsyncValueView(
      value: ref.watch(
        groceryViewProvider.select(
          (view) => view.whenData((view) => view.layout),
        ),
      ),
      error: (_, _) => ErrorState(
        title: l10n.grocery_errorTitle,
        message: l10n.grocery_errorMessage,
        retryLabel: l10n.common_retry,
        onRetry: () => ref.invalidate(groceryItemsProvider),
      ),
      data: (layout) => layout.sections.isEmpty && layout.checkedKeys.isEmpty
          ? EmptyState(
              icon: Symbols.grocery_rounded,
              title: l10n.grocery_emptyTitle,
              message: l10n.grocery_emptyMessage,
            )
          : _Groups(layout: layout),
    );
  }
}

class const _Groups({required final GroceryLayout layout})
    extends StatelessWidget {
  // Room under the last row so the add button never covers it.
  static const double _fabClearance = AppSpacing.space16 + AppSpacing.space8;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ReadingColumn(
      builder: (context, insets) => FadingEdges(
        // Each section's header is pinned at the top, and fading it would
        // wash it out.
        fadeStart: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: insets,
              sliver: SliverMainAxisGroup(
                slivers: [
                  for (final section in layout.sections)
                    _Group(
                      key: ValueKey(section.name),
                      title: l10n.storeSectionName(section.name),
                      entryKeys: section.entryKeys,
                    ),
                  if (layout.checkedKeys.isNotEmpty)
                    _Group(
                      key: const ValueKey(_Group.checkedKey),
                      title: l10n.grocery_checkedSection,
                      entryKeys: layout.checkedKeys,
                    ),
                  const SliverPadding(
                    padding: EdgeInsets.only(bottom: _fabClearance),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One group of rows under a header that stays pinned while it scrolls.
class const _Group({
  required final String title,
  required final List<String> entryKeys,
  super.key,
}) extends StatelessWidget {
  /// Key of the checked group, which can't clash with a section name
  /// because those are never empty.
  static const checkedKey = '';

  @override
  Widget build(BuildContext context) => SliverMainAxisGroup(
    slivers: [
      PinnedHeaderSliver(
        child: ColoredBox(
          color: context.colors.surface,
          child: SectionHeader(title: title),
        ),
      ),
      SliverList.list(
        children: [
          for (final key in entryKeys)
            GroceryEntryRow(key: ValueKey(key), entryKey: key),
        ],
      ),
    ],
  );
}
