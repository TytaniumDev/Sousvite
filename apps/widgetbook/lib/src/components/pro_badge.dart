import 'package:design_system/design_system.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:widgetbook/widgetbook.dart';

final proBadgeComponent = WidgetbookComponent(
  name: 'ProBadge',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => Preview(
        maxWidth: null,
        child: ProBadge(
          label: context.knobs.string(label: 'Label', initialValue: 'Pro'),
        ),
      ),
    ),
  ],
);
