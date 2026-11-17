import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/database.dart';
import 'package:sousvite/features/account/sync/application/sync_source.dart';
import 'package:sousvite/features/account/sync/data/local_setting.dart';

part 'sync_source_controller.g.dart';

/// The Sync source setting (Beta): Sousvite cloud by default during the
/// beta, or the user's Google Drive (ENGINEERING.md §10). Kept on this
/// device.
///
/// Switching goes through `SyncController.switchTo`, which copies the
/// library into the new source before choosing it.
@Riverpod(keepAlive: true)
class SyncSourceController() extends _$SyncSourceController {
  LocalSetting get _setting =>
      LocalSetting(ref.read(appDatabaseProvider).settingsDao, 'sync_source');

  @override
  Future<SyncSource> build() async =>
      SyncSource.fromStoredName(await _setting.read());

  /// Saves [source] as the chosen one.
  Future<void> choose(SyncSource source) async {
    await future;
    await _setting.write(source.storedName);
    state = AsyncData(source);
  }
}
