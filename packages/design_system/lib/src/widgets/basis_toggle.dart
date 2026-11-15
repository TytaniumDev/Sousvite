import 'package:material_ui/material_ui.dart';

/// What nutrition numbers cover.
enum NutritionBasis() {
  /// One serving at the user's serving size.
  perServing,

  /// The whole recipe.
  batch,
}

/// Switches nutrition between per serving and per batch
/// (DESIGN_SYSTEM.md §9.2).
class const BasisToggle({
  /// The basis shown now.
  required final NutritionBasis basis,

  /// Called with the basis the user picks.
  required final ValueChanged<NutritionBasis> onChanged,

  /// "Per serving", already localized.
  required final String perServingLabel,

  /// "Per batch", already localized.
  required final String batchLabel,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SegmentedButton<NutritionBasis>(
    segments: [
      ButtonSegment(value: .perServing, label: Text(perServingLabel)),
      ButtonSegment(value: .batch, label: Text(batchLabel)),
    ],
    selected: {basis},
    showSelectedIcon: false,
    onSelectionChanged: (selection) => onChanged(selection.single),
  );
}
