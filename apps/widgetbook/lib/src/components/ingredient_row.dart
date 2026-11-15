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
          ),
        ),
      ),
    ),
  ],
);
