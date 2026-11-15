import 'package:design_system/design_system.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:sousvite_widgetbook/src/helpers/quantity_knob.dart';
import 'package:units/units.dart';
import 'package:widgetbook/widgetbook.dart';

final ingredientSplitPreviewComponent = WidgetbookComponent(
  name: 'IngredientSplitPreview',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => Preview(
        child: IngredientSplitPreview(
          name: context.knobs.string(label: 'Name', initialValue: 'garlic'),
          quantity: context.knobs.quantity(
            label: 'Quantity',
            initialValue: Quantity(2),
          ),
          unit: context.knobs.stringOrNull(
            label: 'Unit',
            initialValue: 'cloves',
          ),
          preparation: context.knobs.stringOrNull(
            label: 'Preparation',
            initialValue: 'minced',
          ),
          amountLabel: 'Amount',
          nameLabel: 'Ingredient',
          preparationLabel: 'Preparation',
          onEdit: (_) {},
        ),
      ),
    ),
  ],
);
