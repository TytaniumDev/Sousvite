import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// Lays [itemCount] items out in rows, as many to a row as fit at
/// [minItemWidth], for a `CustomScrollView`.
///
/// Rows are laid out by hand rather than with a fixed-ratio grid, so an
/// item is as tall as its text needs at any text size. Rows are built
/// lazily as they scroll in. Give each item a key, so a list change moves
/// items instead of rebuilding them.
class const SliverCardRows({
  /// How many items there are.
  required final int itemCount,

  /// The narrowest an item gets before a row holds one fewer.
  required final double minItemWidth,

  /// Builds the item at an index.
  required final IndexedWidgetBuilder itemBuilder,
  super.key,
}) extends StatelessWidget {
  /// The space between items, across and down.
  static const double gap = AppSpacing.space3;

  /// How many items fit in a row [width] wide.
  static int columnsFor(double width, double minItemWidth) =>
      math.max(1, (width + gap) ~/ (minItemWidth + gap));

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
    sliver: SliverLayoutBuilder(
      builder: (context, constraints) {
        final columns = columnsFor(constraints.crossAxisExtent, minItemWidth);
        return SliverList.separated(
          itemCount: (itemCount / columns).ceil(),
          separatorBuilder: (_, _) => const SizedBox(height: gap),
          itemBuilder: (context, row) {
            final start = row * columns;
            final end = math.min(start + columns, itemCount);
            return Row(
              crossAxisAlignment: .start,
              spacing: gap,
              children: [
                for (var i = start; i < end; i++)
                  Expanded(child: itemBuilder(context, i)),
                // Keeps items in a short last row the same width as above.
                for (var i = end - start; i < columns; i++)
                  const Expanded(child: SizedBox.shrink()),
              ],
            );
          },
        );
      },
    ),
  );
}
