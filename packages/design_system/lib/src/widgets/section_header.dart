import 'package:design_system/src/theme/context_ext.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// A step section's name ("Prep") with its step count, and a drag handle
/// when sections can be reordered (DESIGN_SYSTEM.md §9.2, §10.2).
class const SectionHeader({
  /// The section name: "Prep".
  required final String title,

  /// The step count, already worded: "3 steps". Null hides it.
  final String? countLabel,

  /// This section's index in its `ReorderableListView`. Set it to show a
  /// drag handle that starts a reorder; null when sections are fixed.
  final int? reorderIndex,

  /// What a screen reader says for the drag handle: "Reorder Prep".
  /// Required with [reorderIndex].
  final String? reorderLabel,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    assert(
      (this.reorderIndex == null) == (reorderLabel == null),
      'A drag handle needs its screen reader label.',
    );
    final countLabel = this.countLabel;
    final reorderIndex = this.reorderIndex;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: context.textStyles.titleMedium?.copyWith(
                  color: context.colors.onSurface,
                ),
              ),
            ),
            if (countLabel != null)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.space2),
                child: Text(
                  countLabel,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            if (reorderIndex != null)
              _DragHandle(index: reorderIndex, label: reorderLabel ?? title),
          ],
        ),
      ),
    );
  }
}

class const _DragHandle({required final int index, required final String label})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ReorderableDragStartListener(
    index: index,
    child: SizedBox.square(
      dimension: kMinInteractiveDimension,
      child: Icon(
        Symbols.drag_indicator_rounded,
        semanticLabel: label,
        color: context.colors.onSurfaceVariant,
      ),
    ),
  );
}
