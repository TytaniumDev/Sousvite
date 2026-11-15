import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:widgetbook/widgetbook.dart';

final macroBarComponent = WidgetbookComponent(
  name: 'MacroBar',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => Preview(
        child: MacroBar(
          protein: _grams(context, 'Protein (g)', 31),
          carbs: _grams(context, 'Carbs (g)', 49),
          fat: _grams(context, 'Fat (g)', 4.5),
        ),
      ),
    ),
  ],
);

double _grams(BuildContext context, String label, double initialValue) =>
    context.knobs.double.slider(
      label: label,
      initialValue: initialValue,
      max: 200,
    );
