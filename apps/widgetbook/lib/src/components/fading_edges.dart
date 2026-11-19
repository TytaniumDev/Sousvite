import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';

final fadingEdgesComponent = WidgetbookComponent(
  name: 'FadingEdges',
  useCases: [
    WidgetbookUseCase(
      name: 'List',
      // No Preview: the list fills the window, like a page's scroll view.
      builder: (context) => FadingEdges(
        extent: context.knobs.double.slider(
          label: 'Extent',
          initialValue: FadingEdges.defaultExtent,
          min: AppSpacing.space4,
          max: AppSpacing.space16,
        ),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.space4),
          children: [
            for (var i = 1; i <= 30; i++)
              ListTile(
                title: Text('Step $i'),
                subtitle: const Text('Scroll to see the edges fade.'),
              ),
          ],
        ),
      ),
    ),
  ],
);
