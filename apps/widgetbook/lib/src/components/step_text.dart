import 'package:design_system/design_system.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:sousvite_widgetbook/src/helpers/quantity_knob.dart';
import 'package:units/units.dart';
import 'package:widgetbook/widgetbook.dart';

final stepTextComponent = WidgetbookComponent(
  name: 'StepText',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => Preview(
        child: StepText(
          segments: _segments(
            context.knobs.quantity(
              label: 'Amount',
              initialValue: Quantity(3, 4),
            ),
          ),
          highlightAmounts: context.knobs.boolean(
            label: 'Highlight amounts (editor)',
          ),
        ),
      ),
    ),
    WidgetbookUseCase(
      name: 'Cooking',
      builder: (context) => Preview(
        child: StepText(
          segments: _segments(Quantity(3, 4)),
          style: context.appText.cookingStep,
          amountStyle: context.appText.cookingAmount,
        ),
      ),
    ),
  ],
);

List<StepSegment> _segments(Quantity amount) => [
  const StepTextSegment('Whisk in '),
  StepAmountSegment(quantity: amount, unit: 'cup'),
  const StepTextSegment(' sugar until smooth, then fold in '),
  StepAmountSegment(quantity: Quantity(2), unit: 'eggs'),
  const StepTextSegment('.'),
];
