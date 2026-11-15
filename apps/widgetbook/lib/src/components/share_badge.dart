import 'package:design_system/design_system.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:widgetbook/widgetbook.dart';

final shareBadgeComponent = WidgetbookComponent(
  name: 'ShareBadge',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final kind = context.knobs.object.segmented(
          label: 'Kind',
          options: ShareBadgeKind.values,
          labelBuilder: (kind) => kind.name,
        );
        return Preview(
          maxWidth: null,
          child: ShareBadge(
            kind: kind,
            label: kind == .joint ? 'Shared' : 'Copy',
          ),
        );
      },
    ),
  ],
);
