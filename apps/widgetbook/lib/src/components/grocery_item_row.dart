import 'package:design_system/design_system.dart';
import 'package:sousvite_widgetbook/src/helpers/interactive.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:sousvite_widgetbook/src/helpers/quantity_knob.dart';
import 'package:units/units.dart';
import 'package:widgetbook/widgetbook.dart';

final groceryItemRowComponent = WidgetbookComponent(
  name: 'GroceryItemRow',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => Preview(
        child: Interactive(
          initialValue: context.knobs.boolean(label: 'Checked'),
          builder: (context, checked, onChanged) => GroceryItemRow(
            name: context.knobs.string(
              label: 'Name',
              initialValue: 'Black beans',
            ),
            quantity: context.knobs.quantity(
              label: 'Quantity',
              initialValue: Quantity(3, 2),
            ),
            unit: context.knobs.stringOrNull(
              label: 'Unit',
              initialValue: 'cups',
            ),
            sourcesLabel: context.knobs.stringOrNull(
              label: 'Sources',
              initialValue: 'Chili, Burrito bowls',
            ),
            checked: checked,
            onChanged: onChanged,
          ),
        ),
      ),
    ),
  ],
);
