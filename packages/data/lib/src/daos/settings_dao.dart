import 'package:data/src/app_database.dart';
import 'package:data/src/tables/sync_tables.dart';
import 'package:drift/drift.dart';

part 'settings_dao.g.dart';

/// Queries for the app's settings, kept as text in `local_values`.
@DriftAccessor(tables: [LocalValues])
class SettingsDao(super.attachedDatabase)
    extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  /// The rows stored under [keys]. Missing keys have no row.
  Selectable<LocalValueRow> valuesFor(Set<String> keys) =>
      select(localValues)..where((row) => row.key.isIn(keys));

  /// Stores [value] under [key], replacing what was there.
  Future<void> setValue(String key, String value) => into(
    localValues,
  ).insertOnConflictUpdate(LocalValuesCompanion.insert(key: key, value: value));
}
