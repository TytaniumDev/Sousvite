import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:widgetbook/widgetbook.dart';

final paddedInkWellComponent = WidgetbookComponent(
  name: 'PaddedInkWell',
  useCases: [
    WidgetbookUseCase(
      // Hover or press to see the ink around the text.
      name: 'Default',
      builder: (context) => Preview(
        maxWidth: null,
        child: PaddedInkWell(
          onTap: () {},
          horizontal: context.knobs.double.slider(
            label: 'Horizontal padding',
            initialValue: AppSpacing.space2,
            min: PaddedInkWell.minPadding,
            max: AppSpacing.space6,
          ),
          vertical: context.knobs.double.slider(
            label: 'Vertical padding',
            initialValue: AppSpacing.space2,
            min: PaddedInkWell.minPadding,
            max: AppSpacing.space6,
          ),
          borderRadius: AppRadii.borderSm,
          child: Text(
            context.knobs.string(label: 'Text', initialValue: '2 tsp'),
          ),
        ),
      ),
    ),
  ],
);
