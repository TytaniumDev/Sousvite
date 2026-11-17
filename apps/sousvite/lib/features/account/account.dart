/// The account feature's public surface. Other features import only this
/// file; everything else in this folder is private to the feature.
library;

export 'account_routes.dart';
export 'application/auth_user.dart';
export 'sync/application/shared_spaces.dart' show sharedSpaceIdsProvider;
export 'sync/application/sync_controller.dart' show syncControllerProvider;
export 'sync/presentation/sign_in_callout_card.dart';
export 'sync/presentation/sync_source_setting.dart';
export 'sync/presentation/sync_status_button.dart';
