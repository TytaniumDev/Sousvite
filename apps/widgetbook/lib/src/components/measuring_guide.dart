import 'package:design_system/design_system.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:units/units.dart';
import 'package:widgetbook/widgetbook.dart';

final measuringGuideComponent = WidgetbookComponent(
  name: 'MeasuringGuide',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => Preview(
        child: MeasuringGuide(
          tools: context.knobs.object.dropdown(
            label: 'Tools',
            options: _toolSets,
            labelBuilder: (tools) => tools
                .map((tool) => '${tool.quantity.format()} ${tool.unit}')
                .join(' + '),
          ),
          label: context.knobs.stringOrNull(
            label: 'Label',
            initialValue: 'Use',
          ),
        ),
      ),
    ),
    WidgetbookUseCase(
      name: 'Cooking',
      builder: (context) => Preview(
        child: MeasuringGuide(
          tools: _toolSets.first,
          style: context.appText.cookingIngredient,
        ),
      ),
    ),
  ],
);

final _toolSets = <List<MeasuringGuideTool>>[
  [
    (quantity: Quantity(1, 2), unit: 'cup'),
    (quantity: Quantity(1, 4), unit: 'cup'),
  ],
  [(quantity: Quantity.one, unit: 'Tbsp')],
  [
    (quantity: Quantity.one, unit: 'cup'),
    (quantity: Quantity(1, 3), unit: 'cup'),
    (quantity: Quantity.one, unit: 'Tbsp'),
    (quantity: Quantity(1, 2), unit: 'tsp'),
  ],
];
