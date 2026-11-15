import 'package:design_system/src/theme/context_ext.dart';
import 'package:design_system/src/tokens/radii.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:design_system/src/widgets/amount_text.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:units/units.dart';

/// − 4 servings +: changes how many servings a recipe makes
/// (DESIGN_SYSTEM.md §9.2).
///
/// Steps go to whole numbers, so 2 ½ steps down to 2 and up to 3. The
/// buttons turn off at [min] and [max].
class const ServingStepper({
  /// The servings now. May be a fraction, such as 2 ½.
  required final Quantity servings,

  /// The unit word for [servings], already localized and pluralized:
  /// "servings".
  required final String unit,

  /// Called with the new servings.
  required final ValueChanged<Quantity> onChanged,

  /// The tooltip and screen reader label of the minus button.
  required final String decreaseLabel,

  /// The tooltip and screen reader label of the plus button.
  required final String increaseLabel,

  /// The fewest servings.
  final Quantity min = Quantity.one,

  /// The most servings, or null for no limit.
  final Quantity? max,
  super.key,
}) extends StatelessWidget {
  /// The servings one step down: the whole number below.
  Quantity get _decreased =>
      servings.isWhole ? servings - Quantity.one : Quantity(servings.wholePart);

  /// The servings one step up: the whole number above.
  Quantity get _increased => Quantity(servings.wholePart + 1);

  @override
  Widget build(BuildContext context) {
    final down = _decreased;
    final up = _increased;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.outline),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.full)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Symbols.remove_rounded),
            tooltip: decreaseLabel,
            onPressed: down < min ? null : () => onChanged(down),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space1),
            child: AmountText(
              quantity: servings,
              unit: unit,
              style: context.appText.number.copyWith(
                color: context.colors.onSurface,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Symbols.add_rounded),
            tooltip: increaseLabel,
            onPressed: max != null && up > max! ? null : () => onChanged(up),
          ),
        ],
      ),
    );
  }
}
