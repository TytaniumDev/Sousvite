import 'package:design_system/design_system.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:widgetbook/widgetbook.dart';

final recipeCardComponent = WidgetbookComponent(
  name: 'RecipeCard',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => Preview(
        maxWidth: context.knobs.double.slider(
          label: 'Width',
          initialValue: 200,
          min: 140,
          max: 360,
        ),
        child: RecipeCard(
          title: context.knobs.string(
            label: 'Title',
            initialValue: 'Weeknight chili',
          ),
          totalTimeLabel: context.knobs.stringOrNull(
            label: 'Total time',
            initialValue: '45 min',
          ),
          caloriesLabel: context.knobs.stringOrNull(
            label: 'Calories',
            initialValue: '520 kcal',
          ),
          badges: [
            if (context.knobs.boolean(
              label: 'Shared badge',
              initialValue: true,
            ))
              const ShareBadge(kind: .joint, label: 'Shared'),
            if (context.knobs.boolean(label: 'Experiment badge'))
              const ExperimentBadge(label: 'Experiment'),
          ],
          onTap: () {},
        ),
      ),
    ),
  ],
);
