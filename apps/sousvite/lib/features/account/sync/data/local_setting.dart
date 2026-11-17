import 'package:data/data.dart';

/// One device-only setting, kept as text in the local database's
/// `local_values` and never synced.
final class const LocalSetting(
  /// The database's settings queries.
  final SettingsDao dao,

  /// The key the value is stored under.
  final String key,
) {
  /// The stored value, or null when nothing was stored yet.
  Future<String?> read() async =>
      (await dao.valuesFor({key}).getSingleOrNull())?.value;

  /// Stores [value], replacing what was there.
  Future<void> write(String value) => dao.setValue(key, value);
}
