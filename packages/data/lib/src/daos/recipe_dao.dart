import 'package:data/src/app_database.dart';
import 'package:data/src/tables/folder_tables.dart';
import 'package:data/src/tables/recipe_tables.dart';
import 'package:drift/drift.dart';

part 'recipe_dao.g.dart';

/// Queries for recipes and their ingredient lines, sections, and steps.
///
/// Writes here record no changes: `DriftRecipeRepository` wraps them in a
/// `ChangeRecorder` write, and the sync appliers call them directly.
@DriftAccessor(
  tables: [
    Recipes,
    IngredientSections,
    IngredientLines,
    StepSections,
    RecipeSteps,
    Folders,
    FolderEntries,
  ],
)
class RecipeDao(super.attachedDatabase)
    extends DatabaseAccessor<AppDatabase>
    with _$RecipeDaoMixin {
  /// Every recipe id, newest first.
  Stream<List<String>> watchRecipeIds() =>
      (selectOnly(recipes)
            ..addColumns([recipes.id])
            ..orderBy([
              OrderingTerm.desc(recipes.createdAt),
              OrderingTerm.asc(recipes.id),
            ]))
          .map((row) => row.read(recipes.id)!)
          .watch();

  /// Ids of recipes whose search text matches the FTS5 [match]
  /// expression, newest first.
  ///
  /// The index is written by triggers, so the query re-runs when any table
  /// those triggers read from changes.
  Stream<List<String>> watchSearch(String match) => customSelect(
    'SELECT r.id AS id FROM recipe_search s '
    'INNER JOIN recipes r ON r.id = s.recipe_id '
    'WHERE recipe_search MATCH ?1 '
    'ORDER BY r.created_at DESC, r.id',
    variables: [Variable.withString(match)],
    readsFrom: {recipes, ingredientLines, folders, folderEntries},
  ).map((row) => row.read<String>('id')).watch();

  /// The recipe with [id].
  Selectable<RecipeRow> recipe(String id) =>
      select(recipes)..where((row) => row.id.equals(id));

  /// The ingredient sections of [recipeId] in sort order.
  Selectable<IngredientSectionRow> ingredientSectionsOf(String recipeId) =>
      select(ingredientSections)
        ..where((row) => row.recipeId.equals(recipeId))
        ..orderBy([(row) => OrderingTerm.asc(row.sortKey)]);

  /// The ingredient lines of [recipeId] in sort order.
  Selectable<IngredientLineRow> ingredientLinesOf(String recipeId) =>
      select(ingredientLines)
        ..where((row) => row.recipeId.equals(recipeId))
        ..orderBy([(row) => OrderingTerm.asc(row.sortKey)]);

  /// The step sections of [recipeId] in sort order.
  Selectable<StepSectionRow> stepSectionsOf(String recipeId) =>
      select(stepSections)
        ..where((row) => row.recipeId.equals(recipeId))
        ..orderBy([(row) => OrderingTerm.asc(row.sortKey)]);

  /// The steps of [recipeId] in sort order.
  Selectable<RecipeStepRow> stepsOf(String recipeId) => select(recipeSteps)
    ..where((row) => row.recipeId.equals(recipeId))
    ..orderBy([(row) => OrderingTerm.asc(row.sortKey)]);

  /// The ingredient section with [id].
  Selectable<IngredientSectionRow> ingredientSection(String id) =>
      select(ingredientSections)..where((row) => row.id.equals(id));

  /// The ingredient line with [id].
  Selectable<IngredientLineRow> ingredientLine(String id) =>
      select(ingredientLines)..where((row) => row.id.equals(id));

  /// The step section with [id].
  Selectable<StepSectionRow> stepSection(String id) =>
      select(stepSections)..where((row) => row.id.equals(id));

  /// The step with [id].
  Selectable<RecipeStepRow> step(String id) =>
      select(recipeSteps)..where((row) => row.id.equals(id));

  /// Inserts [row] into [table], or replaces the row with its key.
  Future<void> upsert<T extends Table, R>(
    TableInfo<T, R> table,
    Insertable<R> row,
  ) => into(table).insertOnConflictUpdate(row);

  /// Deletes the recipe row with [id], leaving its parts.
  Future<void> deleteRecipe(String id) =>
      (delete(recipes)..where((row) => row.id.equals(id))).go();

  /// Deletes the ingredient section row with [id].
  Future<void> deleteIngredientSection(String id) =>
      (delete(ingredientSections)..where((row) => row.id.equals(id))).go();

  /// Deletes the ingredient line row with [id].
  Future<void> deleteIngredientLine(String id) =>
      (delete(ingredientLines)..where((row) => row.id.equals(id))).go();

  /// Deletes the step section row with [id].
  Future<void> deleteStepSection(String id) =>
      (delete(stepSections)..where((row) => row.id.equals(id))).go();

  /// Deletes the step row with [id].
  Future<void> deleteStep(String id) =>
      (delete(recipeSteps)..where((row) => row.id.equals(id))).go();
}
