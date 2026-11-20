import 'package:design_system/design_system.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';
import 'package:widgetbook/widgetbook.dart';

final syncStatusIconComponent = WidgetbookComponent(
  name: 'SyncStatusIcon',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final status = context.knobs.object.segmented(
          label: 'Status',
          options: SyncIconStatus.values,
          labelBuilder: (status) => status.name,
        );
        return Preview(
          maxWidth: null,
          child: SyncStatusIcon(
            status: status,
            label: _labels[status]!,
            onTap: context.knobs.boolean(label: 'Tappable') ? () {} : null,
          ),
        );
      },
    ),
  ],
);

const Map<SyncIconStatus, String> _labels = {
  SyncIconStatus.synced: 'Synced',
  SyncIconStatus.syncing: 'Syncing',
  SyncIconStatus.offline: 'Offline. Changes sync when you reconnect',
  SyncIconStatus.error: 'Sync failed',
};
