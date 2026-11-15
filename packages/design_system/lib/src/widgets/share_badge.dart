import 'package:design_system/src/theme/context_ext.dart';
import 'package:design_system/src/widgets/status_pill.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// How a recipe was shared with the person looking at it.
enum ShareBadgeKind() {
  /// A joint share: everyone in it edits the same recipe.
  joint,

  /// A copy someone sent, not yet edited.
  copy,
}

/// "Shared" or "Copy", so people know whether their edits reach others
/// (DESIGN_SYSTEM.md §9.2, §10.7).
class const ShareBadge({
  /// Which kind of share this recipe is.
  required final ShareBadgeKind kind,

  /// The word for [kind], already localized: "Shared", "Copy".
  required final String label,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return switch (kind) {
      .joint => StatusPill(
        icon: Symbols.group_rounded,
        label: label,
        background: colors.secondaryContainer,
        foreground: colors.onSecondaryContainer,
      ),
      .copy => StatusPill(
        icon: Symbols.content_copy_rounded,
        label: label,
        background: colors.surfaceContainerHigh,
        foreground: colors.onSurface,
      ),
    };
  }
}
