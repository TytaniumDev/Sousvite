import 'package:design_system/design_system.dart';
import 'package:sousvite_widgetbook/src/helpers/interactive.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:sousvite_widgetbook/src/helpers/quantity_knob.dart';
import 'package:units/units.dart';
import 'package:widgetbook/widgetbook.dart';

final servingStepperComponent = WidgetbookComponent(
  name: 'ServingStepper',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => Preview(
        maxWidth: null,
        child: Interactive(
          initialValue: context.knobs.quantity(
            label: 'Servings',
            initialValue: Quantity(4),
          ),
          builder: (context, servings, onChanged) => ServingStepper(
            servings: servings,
            unit: context.knobs.string(label: 'Unit', initialValue: 'servings'),
            max: Quantity(12),
            onChanged: onChanged,
            decreaseLabel: 'Fewer servings',
            increaseLabel: 'More servings',
          ),
        ),
      ),
    ),
  ],
);
