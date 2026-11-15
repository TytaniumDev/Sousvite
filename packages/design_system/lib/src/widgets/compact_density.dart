import 'package:material_ui/material_ui.dart';

/// Makes its subtree compact: the detailed nutrients table, the match
/// review list, and the read-only ingredient list (DESIGN_SYSTEM.md §6.2).
///
/// Applies `VisualDensity.compact` and the compact row height. Anything
/// tappable keeps its 48 dp hit area, because the tap target size is left
/// padded.
class const CompactDensity({
  /// The subtree to make compact.
  required final Widget child,
  super.key,
}) extends StatelessWidget {
  /// The height of a compact row.
  static const double rowHeight = 40;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        visualDensity: VisualDensity.compact,
        listTileTheme: theme.listTileTheme.copyWith(minTileHeight: rowHeight),
      ),
      child: child,
    );
  }
}
