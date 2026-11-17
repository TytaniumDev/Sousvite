import 'package:data/src/app_database.dart';
import 'package:data/src/change_log/change_recorder.dart';
import 'package:data/src/change_log/entity_applier.dart';
import 'package:data/src/change_log/materializing_applier.dart';
import 'package:data/src/daos/user_recipe_prefs_dao.dart';
import 'package:data/src/prefs/prefs_codecs.dart';
import 'package:domain/domain.dart';

/// [UserRecipePrefsRepository] over the local database. Prefs sync across
/// the user's own devices in their private space.
final class DriftUserRecipePrefsRepository(
  /// The database the prefs and the change log live in.
  final AppDatabase database, {

  /// Records each write's changes for sync.
  required final ChangeRecorder recorder,
}) implements UserRecipePrefsRepository {
  UserRecipePrefsDao get _dao => database.userRecipePrefsDao;

  static final _codec = UserRecipePrefsCodec();

  /// Writes remote changes for prefs, for `DriftLocalStore`.
  Map<String, EntityApplier> get appliers => {
    _codec.entity: MaterializingApplier(
      database,
      codec: _codec,
      write: (prefs) => _dao.upsert(_toCompanion(prefs)),
      remove: _dao.deletePrefs,
    ),
  };

  @override
  Stream<UserRecipePrefs?> watchPrefs(RecipeId recipeId) => _dao
      .prefsOf(recipeId.value)
      .watchSingleOrNull()
      .map((row) => row == null ? null : _toEntity(row))
      .distinct();

  @override
  Future<void> savePrefs(UserRecipePrefs prefs) => recorder.write((
    changes,
  ) async {
    final before = await _dao.prefsOf(prefs.recipeId.value).getSingleOrNull();
    changes.setChanged(
      _codec,
      prefs,
      before: before == null ? null : _toEntity(before),
    );
    await _dao.upsert(_toCompanion(prefs));
  });

  static UserRecipePrefs _toEntity(UserRecipePrefsRow row) => UserRecipePrefs(
    recipeId: RecipeId(row.recipeId),
    servings: Quantity(row.servingsNumerator, row.servingsDenominator),
    unitSystem: row.unitSystem,
  );

  static UserRecipePrefsTableCompanion _toCompanion(UserRecipePrefs prefs) =>
      UserRecipePrefsTableCompanion.insert(
        recipeId: prefs.recipeId.value,
        servingsNumerator: prefs.servings.numerator,
        servingsDenominator: prefs.servings.denominator,
        unitSystem: prefs.unitSystem,
      );
}
