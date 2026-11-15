import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:widgetbook/widgetbook.dart';

final matchStatusChipComponent = WidgetbookComponent(
  name: 'MatchStatusChip',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final status = context.knobs.object.segmented(
          label: 'Status',
          options: MatchStatus.values,
          labelBuilder: (status) => status.name,
        );
        return Preview(
          maxWidth: null,
          child: MatchStatusChip(status: status, label: _labels[status]!),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'All statuses',
      builder: (context) => Preview(
        maxWidth: null,
        child: Wrap(
          spacing: AppSpacing.space2,
          runSpacing: AppSpacing.space2,
          children: [
            for (final MapEntry(key: status, value: label) in _labels.entries)
              MatchStatusChip(status: status, label: label),
          ],
        ),
      ),
    ),
  ],
);

const Map<MatchStatus, String> _labels = {
  MatchStatus.usda: 'USDA',
  MatchStatus.openFoodFacts: 'Open Food Facts',
  MatchStatus.edited: 'Edited',
  MatchStatus.notMatched: 'Not matched',
};
