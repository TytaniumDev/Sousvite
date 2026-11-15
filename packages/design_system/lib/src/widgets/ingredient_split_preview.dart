import 'package:design_system/src/theme/context_ext.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:design_system/src/widgets/amount_text.dart';
import 'package:material_ui/material_ui.dart';
import 'package:units/units.dart';

/// A part of a typed ingredient line that the parser split out.
enum IngredientPart() {
  /// "2 cups".
  amount,

  /// "flour".
  name,

  /// "sifted".
  preparation,
}

/// How a typed ingredient line was split: amount, ingredient, and
/// preparation as chips the user can tap to fix (DESIGN_SYSTEM.md §9.2,
/// §10.2).
///
/// Parts the parser did not find are left out. Words come from the caller
/// (already localized), since `design_system` has no strings of its own.
class const IngredientSplitPreview({
  /// The ingredient: "flour".
  required final String name,

  /// What a screen reader says before the amount: "Amount".
  required final String amountLabel,

  /// What a screen reader says before [name]: "Ingredient".
  required final String nameLabel,

  /// What a screen reader says before [preparation]: "Preparation".
  required final String preparationLabel,

  /// The parsed amount, or null when the line has none.
  final Quantity? quantity,

  /// The parsed unit word, already localized: "cups". Null for a bare
  /// count.
  final String? unit,

  /// How it is prepared, or null when there is none.
  final String? preparation,

  /// Called with the part the user tapped. Null shows the split read-only.
  final ValueChanged<IngredientPart>? onEdit,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final quantity = this.quantity;
    final preparation = this.preparation;
    return Wrap(
      spacing: AppSpacing.space2,
      runSpacing: AppSpacing.space2,
      children: [
        if (quantity != null)
          _PartChip(
            part: .amount,
            value: AmountText.textFor(quantity, unit),
            label: amountLabel,
            onEdit: onEdit,
          ),
        _PartChip(part: .name, value: name, label: nameLabel, onEdit: onEdit),
        if (preparation != null)
          _PartChip(
            part: .preparation,
            value: preparation,
            label: preparationLabel,
            onEdit: onEdit,
          ),
      ],
    );
  }
}

class const _PartChip({
  required final IngredientPart part,
  required final String value,
  required final String label,
  required final ValueChanged<IngredientPart>? onEdit,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, foreground) = switch (part) {
      .amount => (colors.primaryContainer, colors.onPrimaryContainer),
      .name => (colors.surfaceContainerHigh, colors.onSurface),
      .preparation => (colors.secondaryContainer, colors.onSecondaryContainer),
    };
    final onEdit = this.onEdit;
    return ActionChip(
      label: Text(value, semanticsLabel: '$label, $value'),
      labelStyle: context.textStyles.labelLarge?.copyWith(color: foreground),
      backgroundColor: background,
      side: BorderSide.none,
      onPressed: onEdit == null ? null : () => onEdit(part),
    );
  }
}
