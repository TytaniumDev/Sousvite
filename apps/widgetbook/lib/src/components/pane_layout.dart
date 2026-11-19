import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';

final paneLayoutComponent = WidgetbookComponent(
  name: 'PaneLayout',
  useCases: [
    WidgetbookUseCase(
      name: 'Supporting pane',
      // No Preview: the layout fills the window, so pick a tablet or desktop
      // in the Viewport addon to see the side pane.
      builder: (context) => PaneLayout(
        sideAt: context.knobs.object.dropdown(
          label: 'Side pane at',
          options: PaneSide.values,
          labelBuilder: (side) => side.name,
        ),
        side: (context, insets) => _Pane(insets: insets, lines: _ingredients),
        main: (context, insets) => _Pane(insets: insets, lines: _steps),
        onePane: (context, insets) =>
            _Pane(insets: insets, lines: const [..._ingredients, ..._steps]),
      ),
    ),
  ],
);

const _ingredients = [
  'Ingredients',
  '½ cup vegan butter',
  '½ cup brown sugar',
  '½ cup granulated sugar',
  '2 flax eggs',
  '1 ½ cups rolled oats',
];

const _steps = [
  'Steps',
  '1  Prepare 2 flax eggs.',
  '2  Cream the butter and both sugars until thick and creamy.',
  '3  Stir in the flax eggs, then the oats, until just combined.',
  '4  Bake at 350 °F for 10 to 12 minutes.',
];

/// A scroll view of sample lines, padded like a real pane.
class const _Pane({
  required final EdgeInsets insets,
  required final List<String> lines,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListView(
    padding: insets + const EdgeInsets.all(AppSpacing.space4),
    children: [
      for (final line in lines)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space3),
          child: Text(line, style: context.textStyles.bodyLarge),
        ),
    ],
  );
}
