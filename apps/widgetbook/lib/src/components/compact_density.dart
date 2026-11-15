import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:units/units.dart';
import 'package:widgetbook/widgetbook.dart';

final compactDensityComponent = WidgetbookComponent(
  name: 'CompactDensity',
  useCases: [
    WidgetbookUseCase(
      name: 'Ingredient list',
      builder: (context) {
        final rows = Column(
          mainAxisSize: .min,
          children: [
            IngredientRow(name: 'Flour', quantity: Quantity(2), unit: 'cups'),
            IngredientRow(
              name: 'Baking soda',
              quantity: Quantity(1, 2),
              unit: 'tsp',
            ),
            IngredientRow(name: 'Salt', quantity: Quantity(1, 4), unit: 'tsp'),
          ],
        );
        return Preview(
          child: context.knobs.boolean(label: 'Compact', initialValue: true)
              ? CompactDensity(child: rows)
              : rows,
        );
      },
    ),
  ],
);
