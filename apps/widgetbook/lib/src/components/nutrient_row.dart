import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:widgetbook/widgetbook.dart';

final nutrientRowComponent = WidgetbookComponent(
  name: 'NutrientRow',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => Preview(
        child: NutrientRow(
          label: context.knobs.string(label: 'Label', initialValue: 'Fiber'),
          value: context.knobs.double.input(label: 'Value', initialValue: 4.04),
          unit: context.knobs.string(label: 'Unit', initialValue: 'g'),
          precision: context.knobs.object.segmented(
            label: 'Precision',
            options: NutrientPrecision.values,
            initialOption: NutrientPrecision.grams,
            labelBuilder: (precision) => precision.name,
          ),
          indent: context.knobs.int.slider(
            label: 'Indent',
            max: 2,
            divisions: 2,
          ),
        ),
      ),
    ),
    WidgetbookUseCase(
      name: 'Table in compact density',
      builder: (context) => const Preview(
        child: CompactDensity(
          child: Column(
            mainAxisSize: .min,
            children: [
              NutrientRow(label: 'Calories', value: 523.6, unit: 'kcal'),
              NutrientRow(label: 'Fat', value: 4.46, unit: 'g'),
              NutrientRow(
                label: 'Saturated fat',
                value: 1.2,
                unit: 'g',
                indent: 1,
              ),
              NutrientRow(
                label: 'Sodium',
                value: 612,
                unit: 'mg',
                precision: .whole,
              ),
            ],
          ),
        ),
      ),
    ),
  ],
);
