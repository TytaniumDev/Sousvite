import 'package:data/src/app_database.dart';
import 'package:data/src/change_log/change_recorder.dart';
import 'package:data/src/change_log/entity_applier.dart';
import 'package:data/src/change_log/field_values.dart';
import 'package:data/src/change_log/materializing_applier.dart';
import 'package:data/src/daos/settings_dao.dart';
import 'package:data/src/prefs/prefs_codecs.dart';
import 'package:domain/domain.dart';

/// [AppSettingsRepository] over the local database.
///
/// The unit system syncs, so a choice made on the phone applies on the
/// laptop too. The theme stays on each device, since a phone and a laptop
/// can reasonably differ (light in the kitchen, dark at night).
final class DriftAppSettingsRepository(
  /// The database the settings and the change log live in.
  final AppDatabase database, {

  /// Records each write's changes for sync.
  required final ChangeRecorder recorder,
}) implements AppSettingsRepository {
  SettingsDao get _dao => database.settingsDao;

  static final _codec = SyncedSettingsCodec();
  static const _themeKey = 'theme';
  static const _unitSystemKey = 'unit_system';

  /// Writes remote changes for the synced settings, for `DriftLocalStore`.
  Map<String, EntityApplier> get appliers => {
    _codec.entity: MaterializingApplier(
      database,
      codec: _codec,
      write: (settings) =>
          _dao.setValue(_unitSystemKey, settings.unitSystem.name),
      // Settings are never deleted.
      remove: (_) async {},
    ),
  };

  @override
  Stream<AppSettings> watchSettings() =>
      _dao.valuesFor({_themeKey, _unitSystemKey}).watch().map((rows) {
        final values = {for (final row in rows) row.key: row.value};
        return AppSettings(
          theme:
              decodeEnum(ThemePreference.values, values[_themeKey]) ??
              ThemePreference.system,
          unitSystem:
              decodeEnum(UnitSystem.values, values[_unitSystemKey]) ??
              UnitSystem.original,
        );
      }).distinct();

  @override
  Future<void> saveSettings(AppSettings settings) =>
      recorder.write((changes) async {
        final before = await watchSettings().first;
        if (settings.unitSystem != before.unitSystem) {
          changes.setChanged(_codec, settings, before: before);
          await _dao.setValue(_unitSystemKey, settings.unitSystem.name);
        }
        if (settings.theme != before.theme) {
          await _dao.setValue(_themeKey, settings.theme.name);
        }
      });
}
