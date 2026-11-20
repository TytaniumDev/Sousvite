import 'package:design_system/design_system.dart';
import 'package:sousvite_widgetbook/src/helpers/interactive.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:sousvite_widgetbook/src/helpers/quantity_knob.dart';
import 'package:units/units.dart';
import 'package:widgetbook/widgetbook.dart';

final ingredientRowComponent = WidgetbookComponent(
  name: 'IngredientRow',
  useCases: [
    WidgetbookUseCase(
      name: 'Read-only',
      builder: (context) => Preview(
        child: IngredientRow(
          name: context.knobs.string(label: 'Name', initialValue: 'Flour'),
          quantity: context.knobs.quantity(
            label: 'Quantity',
            initialValue: Quantity(9, 4),
          ),
          unit: context.knobs.stringOrNull(label: 'Unit', initialValue: 'cups'),
          preparation: context.knobs.stringOrNull(
            label: 'Preparation',
            initialValue: 'sifted',
          ),
        ),
      ),
    ),
    WidgetbookUseCase(
      name: 'With checkbox',
      builder: (context) => Preview(
        child: Interactive(
          initialValue: context.knobs.boolean(label: 'Checked'),
          builder: (context, checked, onChanged) => IngredientRow(
            name: 'Yellow onion',
            quantity: Quantity.one,
            preparation: 'finely diced',
            checked: checked,
            onChanged: onChanged,
            checkStyle: context.knobs.object.dropdown(
              label: 'Check style',
              options: IngredientCheckStyle.values,
              labelBuilder: (style) => style.name,
            ),
          ),
        ),
      ),
    ),
    WidgetbookUseCase(
      name: 'With measuring guide',
      builder: (context) => Preview(
        child: Interactive(
          initialValue: false,
          builder: (context, checked, onChanged) => IngredientRow(
            name: 'Kosher salt',
            quantity: Quantity(3, 2),
            unit: 'tsp',
            checked: checked,
            onChanged: onChanged,
            guide: MeasuringGuide(
              label: context.knobs.string(label: 'Label', initialValue: 'Use'),
              tools: [(quantity: Quantity(1, 2), unit: 'Tbsp')],
            ),
          ),
        ),
      ),
    ),
    WidgetbookUseCase(
      name: 'With tappable amount',
      builder: (context) => Preview(
        child: Interactive(
          initialValue: false,
          builder: (context, jarred, onChanged) => IngredientRow(
            name: 'garlic',
            quantity: jarred ? Quantity(3, 2) : Quantity(3),
            unit: jarred ? 'tsp' : 'cloves',
            preparation: 'minced',
            onAmountTap: () => onChanged(!jarred),
            amountTapLabel: jarred
                ? 'Show as garlic cloves'
                : 'Show as jarred garlic',
          ),
        ),
      ),
    ),
  ],
);
