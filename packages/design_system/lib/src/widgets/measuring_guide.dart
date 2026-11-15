import 'package:design_system/src/theme/context_ext.dart';
import 'package:design_system/src/tokens/radii.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:design_system/src/widgets/amount_text.dart';
import 'package:material_ui/material_ui.dart';
import 'package:units/units.dart';

/// One measuring tool in a [MeasuringGuide]: its size and the localized
/// unit word, such as (`Quantity(1, 2)`, "cup").
typedef MeasuringGuideTool = ({Quantity quantity, String unit});

/// Which measuring tools to use for an amount: `½ cup` + `¼ cup`
/// (DESIGN_SYSTEM.md §9.2, §10.3).
///
/// `packages/measuring` picks the fewest tools the user owns; this widget
/// shows its result. The tools wrap onto more lines when space runs out.
class const MeasuringGuide({
  /// The tools in the order to use them: ½ cup, then ¼ cup.
  required final List<MeasuringGuideTool> tools,

  /// The style of the tool labels. Defaults to `labelLarge`; cooking mode
  /// passes `context.appText.cookingIngredient`.
  final TextStyle? style,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? context.textStyles.labelLarge;
    return Wrap(
      spacing: AppSpacing.space2,
      runSpacing: AppSpacing.space2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (index, tool) in tools.indexed) ...[
          if (index > 0) _Plus(style: textStyle),
          _Tool(tool: tool, style: textStyle),
        ],
      ],
    );
  }
}

class const _Tool({
  required final MeasuringGuideTool tool,
  required final TextStyle? style,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surfaceContainerHigh,
      borderRadius: AppRadii.borderSm,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space1,
      ),
      child: AmountText(
        quantity: tool.quantity,
        unit: tool.unit,
        style: style?.copyWith(color: context.colors.onSurface),
      ),
    ),
  );
}

class const _Plus({required final TextStyle? style}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Text('+', style: style?.copyWith(color: context.colors.onSurfaceVariant));
}
