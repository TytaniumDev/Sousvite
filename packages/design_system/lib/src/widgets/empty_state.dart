import 'package:design_system/src/theme/context_ext.dart';
import 'package:design_system/src/widgets/state_message.dart';
import 'package:material_ui/material_ui.dart';

/// What an empty space is for, and the one action that fills it
/// (DESIGN_SYSTEM.md §9.2, §10.8).
class const EmptyState({
  /// An icon for what belongs here: `Symbols.menu_book_rounded`.
  required final IconData icon,

  /// The heading, already localized: "No recipes yet".
  required final String title,

  /// One sentence, already localized: "Paste a link or write your own."
  required final String message,

  /// The action that fills the space, usually a `FilledButton`. Null for
  /// none.
  final Widget? action,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StateMessage(
    icon: icon,
    iconColor: context.colors.onSurfaceVariant,
    title: title,
    message: message,
    action: action,
  );
}
