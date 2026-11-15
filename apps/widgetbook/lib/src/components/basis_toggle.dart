import 'package:design_system/design_system.dart';
import 'package:sousvite_widgetbook/src/helpers/interactive.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:widgetbook/widgetbook.dart';

final basisToggleComponent = WidgetbookComponent(
  name: 'BasisToggle',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => Preview(
        maxWidth: null,
        child: Interactive(
          initialValue: context.knobs.object.segmented(
            label: 'Basis',
            options: NutritionBasis.values,
            labelBuilder: (basis) => basis.name,
          ),
          builder: (context, basis, onChanged) => BasisToggle(
            basis: basis,
            onChanged: onChanged,
            perServingLabel: 'Per serving',
            batchLabel: 'Whole batch',
          ),
        ),
      ),
    ),
  ],
);
