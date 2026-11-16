import 'package:data/src/change_log/entity_codec.dart';
import 'package:data/src/change_log/field_values.dart';
import 'package:domain/domain.dart';

/// [UserRecipePrefs] fields in the change log, stored under the recipe id.
final class UserRecipePrefsCodec() implements EntityCodec<UserRecipePrefs> {
  @override
  String get entity => 'user_recipe_prefs';

  @override
  String idOf(UserRecipePrefs value) => value.recipeId.value;

  @override
  Map<String, Object?> encode(UserRecipePrefs value) => {
    'servings': encodeQuantity(value.servings),
    'unitSystem': encodeEnum(value.unitSystem),
  };

  @override
  UserRecipePrefs? decode(String id, Map<String, Object?> fields) {
    final servings = decodeQuantity(fields['servings']);
    if (servings == null) return null;
    return UserRecipePrefs(
      recipeId: RecipeId(id),
      servings: servings,
      unitSystem:
          decodeEnum(UnitSystem.values, fields['unitSystem']) ??
          UnitSystem.original,
    );
  }
}

/// [MeasuringTool] fields in the change log.
final class MeasuringToolCodec() implements EntityCodec<MeasuringTool> {
  @override
  String get entity => 'measuring_tool';

  @override
  String idOf(MeasuringTool value) => value.id.value;

  @override
  Map<String, Object?> encode(MeasuringTool value) => {
    'capacity': encodeQuantity(value.capacity),
    'unit': encodeEnum(value.unit),
  };

  @override
  MeasuringTool? decode(String id, Map<String, Object?> fields) {
    final capacity = decodeQuantity(fields['capacity']);
    final unit = decodeEnum(Unit.values, fields['unit']);
    if (capacity == null || unit == null) return null;
    return MeasuringTool(
      id: MeasuringToolId(id),
      capacity: capacity,
      unit: unit,
    );
  }
}

/// The [AppSettings] that sync, under the single id [settingsId]. The
/// theme is left out: it stays on each device.
final class SyncedSettingsCodec() implements EntityCodec<AppSettings> {
  /// The id the user's settings are stored under.
  static const settingsId = 'user';

  @override
  String get entity => 'app_settings';

  @override
  String idOf(AppSettings value) => settingsId;

  @override
  Map<String, Object?> encode(AppSettings value) => {
    'unitSystem': encodeEnum(value.unitSystem),
  };

  @override
  AppSettings? decode(String id, Map<String, Object?> fields) {
    final unitSystem = decodeEnum(UnitSystem.values, fields['unitSystem']);
    return unitSystem == null ? null : AppSettings(unitSystem: unitSystem);
  }
}
