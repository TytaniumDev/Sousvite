import 'package:design_system/src/theme/context_ext.dart';
import 'package:design_system/src/widgets/status_pill.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// Marks an experiment, in terracotta (DESIGN_SYSTEM.md §9.2, §10.7).
class const ExperimentBadge({
  /// The word, already localized: "Experiment".
  required final String label,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StatusPill(
    icon: Symbols.science_rounded,
    label: label,
    background: context.colors.tertiaryContainer,
    foreground: context.colors.onTertiaryContainer,
  );
}
