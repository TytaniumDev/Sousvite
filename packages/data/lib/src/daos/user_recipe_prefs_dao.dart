import 'package:data/src/app_database.dart';
import 'package:data/src/tables/user_recipe_prefs_tables.dart';
import 'package:drift/drift.dart';

part 'user_recipe_prefs_dao.g.dart';

/// Queries for each recipe's serving size and units.
@DriftAccessor(tables: [UserRecipePrefsTable])
class UserRecipePrefsDao(super.attachedDatabase)
    extends DatabaseAccessor<AppDatabase>
    with _$UserRecipePrefsDaoMixin {
  /// The prefs of [recipeId].
  Selectable<UserRecipePrefsRow> prefsOf(String recipeId) =>
      select(userRecipePrefsTable)
        ..where((row) => row.recipeId.equals(recipeId));

  /// Inserts or replaces a prefs row.
  Future<void> upsert(UserRecipePrefsTableCompanion row) =>
      into(userRecipePrefsTable).insertOnConflictUpdate(row);

  /// Deletes the prefs of [recipeId].
  Future<void> deletePrefs(String recipeId) => (delete(
    userRecipePrefsTable,
  )..where((row) => row.recipeId.equals(recipeId))).go();
}
