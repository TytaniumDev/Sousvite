import 'package:data/src/app_database.steps.dart';
import 'package:data/src/daos/folder_dao.dart';
import 'package:data/src/daos/food_dao.dart';
import 'package:data/src/daos/grocery_dao.dart';
import 'package:data/src/daos/history_dao.dart';
import 'package:data/src/daos/measuring_tool_dao.dart';
import 'package:data/src/daos/recipe_dao.dart';
import 'package:data/src/daos/settings_dao.dart';
import 'package:data/src/daos/sync_dao.dart';
import 'package:data/src/daos/user_recipe_prefs_dao.dart';
import 'package:data/src/tables/folder_tables.dart';
import 'package:data/src/tables/food_tables.dart';
import 'package:data/src/tables/grocery_tables.dart';
import 'package:data/src/tables/history_tables.dart';
import 'package:data/src/tables/measuring_tool_tables.dart';
import 'package:data/src/tables/recipe_tables.dart';
import 'package:data/src/tables/sync_tables.dart';
import 'package:data/src/tables/user_recipe_prefs_tables.dart';
import 'package:domain/domain.dart';
import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// The local database, the app's single source of truth (ENGINEERING.md §7).
///
/// The app opens the platform connection (native SQLite, or WebAssembly on
/// web) and passes it in, so this package stays pure Dart and tests can use
/// an in-memory database.
@DriftDatabase(
  tables: [
    Recipes,
    IngredientSections,
    IngredientLines,
    StepSections,
    RecipeSteps,
    Folders,
    FolderEntries,
    Foods,
    FoodNutrients,
    FoodPortions,
    NutritionMatches,
    RecipeVersions,
    Experiments,
    GroceryLists,
    GroceryItems,
    MeasuringTools,
    UserRecipePrefsTable,
    ChangeLog,
    SyncState,
    LocalValues,
  ],
  include: {'recipes/recipe_search.drift'},
  daos: [
    RecipeDao,
    FolderDao,
    FoodDao,
    HistoryDao,
    GroceryDao,
    MeasuringToolDao,
    UserRecipePrefsDao,
    SettingsDao,
    SyncDao,
  ],
)
class AppDatabase(super.e) extends _$AppDatabase {
  /// Bump this with every schema change, add the step to [migration], and
  /// run `dart run drift_dev make-migrations` to snapshot the new schema.
  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: stepByStep(
      // v2: ingredient lines keep a count word ("clove") as text.
      from1To2: (m, schema) =>
          m.addColumn(schema.ingredientLines, schema.ingredientLines.countWord),
      // v3: grocery items keep the count word of the line they came from.
      from2To3: (m, schema) =>
          m.addColumn(schema.groceryItems, schema.groceryItems.countWord),
      // v4: this device's own values, and the recipe search index, filled
      // from the recipes already saved.
      from3To4: (m, schema) async {
        await m.createTable(schema.localValues);
        await m.createTable(schema.recipeSearch);
        // Schema snapshots leave triggers out, so they come from the
        // current schema.
        for (final trigger in allSchemaEntities.whereType<Trigger>()) {
          await m.create(trigger);
        }
        await rebuildRecipeSearch();
      },
      // v5: grocery items the user separated stop combining by food.
      from4To5: (m, schema) =>
          m.addColumn(schema.groceryItems, schema.groceryItems.combinesByFood),
    ),
  );
}
