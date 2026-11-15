import 'package:design_system/src/theme/context_ext.dart';
import 'package:design_system/src/widgets/status_pill.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// Marks a feature that needs Pro, where it's offered (DESIGN_SYSTEM.md
/// §9.2, §10.10).
class const ProBadge({
  /// The word, already localized: "Pro".
  required final String label,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StatusPill(
    icon: Symbols.workspace_premium_rounded,
    label: label,
    background: context.colors.primaryContainer,
    foreground: context.colors.onPrimaryContainer,
  );
}
