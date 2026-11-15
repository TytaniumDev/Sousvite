import 'package:design_system/design_system.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:sousvite_widgetbook/src/helpers/quantity_knob.dart';
import 'package:units/units.dart';
import 'package:widgetbook/widgetbook.dart';

final amountTextComponent = WidgetbookComponent(
  name: 'AmountText',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => Preview(
        maxWidth: null,
        child: AmountText(
          quantity: context.knobs.quantity(
            label: 'Quantity',
            initialValue: Quantity(3, 2),
          ),
          unit: context.knobs.stringOrNull(label: 'Unit', initialValue: 'cups'),
        ),
      ),
    ),
    WidgetbookUseCase(
      name: 'Cooking',
      builder: (context) => Preview(
        maxWidth: null,
        child: AmountText(
          quantity: context.knobs.quantity(
            label: 'Quantity',
            initialValue: Quantity(3, 4),
          ),
          unit: context.knobs.stringOrNull(label: 'Unit', initialValue: 'cup'),
          style: context.appText.cookingAmount,
        ),
      ),
    ),
  ],
);
