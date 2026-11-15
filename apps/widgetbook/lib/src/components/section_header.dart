import 'package:design_system/design_system.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:widgetbook/widgetbook.dart';

final sectionHeaderComponent = WidgetbookComponent(
  name: 'SectionHeader',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => Preview(
        child: SectionHeader(
          title: context.knobs.string(label: 'Title', initialValue: 'Prep'),
          countLabel: context.knobs.stringOrNull(
            label: 'Count label',
            initialValue: '3 steps',
          ),
        ),
      ),
    ),
    WidgetbookUseCase(
      // The drag handle only needs a reorderable list once a drag starts.
      name: 'Reorderable (editor)',
      builder: (context) => const Preview(
        child: SectionHeader(
          title: 'Prep',
          countLabel: '3 steps',
          reorderIndex: 0,
          reorderLabel: 'Reorder Prep',
        ),
      ),
    ),
  ],
);
