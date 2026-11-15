import 'package:design_system/design_system.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:widgetbook/widgetbook.dart';

final macroSummaryComponent = WidgetbookComponent(
  name: 'MacroSummary',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => Preview(
        child: MacroSummary(
          calories: context.knobs.double.input(
            label: 'Calories',
            initialValue: 523.6,
          ),
          protein: context.knobs.double.input(
            label: 'Protein (g)',
            initialValue: 31.2,
          ),
          carbs: context.knobs.double.input(
            label: 'Carbs (g)',
            initialValue: 48.7,
          ),
          fat: context.knobs.double.input(label: 'Fat (g)', initialValue: 4.46),
          basisLabel: context.knobs.string(
            label: 'Basis label',
            initialValue: 'Per serving (1 of 4)',
          ),
          labels: macroLabels,
        ),
      ),
    ),
  ],
);

/// The English labels the app passes to nutrition widgets.
const macroLabels = MacroLabels(
  calories: 'Calories',
  protein: 'Protein',
  carbs: 'Carbs',
  fat: 'Fat',
  grams: 'g',
);
