/// Entities, value objects, repository interfaces and pure logic for
/// Sousvite.
library;

// Quantities and units live in their own package so design_system can use
// them without depending on the domain. Re-exported here, so domain users
// import one library.
export 'package:units/units.dart';

export 'src/entities/app_settings.dart';
export 'src/entities/experiment.dart';
export 'src/entities/folder.dart';
export 'src/entities/folder_entry.dart';
export 'src/entities/food.dart';
export 'src/entities/food_nutrient.dart';
export 'src/entities/food_portion.dart';
export 'src/entities/grocery_item.dart';
export 'src/entities/grocery_list.dart';
export 'src/entities/ingredient_line.dart';
export 'src/entities/ingredient_section.dart';
export 'src/entities/measuring_tool.dart';
export 'src/entities/nutrition_match.dart';
export 'src/entities/recipe.dart';
export 'src/entities/recipe_snapshot.dart';
export 'src/entities/recipe_step.dart';
export 'src/entities/recipe_version.dart';
export 'src/entities/step_section.dart';
export 'src/entities/user_recipe_prefs.dart';
export 'src/grocery/combine_amounts.dart';
export 'src/grocery/grocery_key.dart';
export 'src/grocery/store_section.dart';
export 'src/repositories/app_settings_repository.dart';
export 'src/repositories/experiment_repository.dart';
export 'src/repositories/folder_repository.dart';
export 'src/repositories/food_repository.dart';
export 'src/repositories/grocery_repository.dart';
export 'src/repositories/measuring_tool_repository.dart';
export 'src/repositories/recipe_repository.dart';
export 'src/repositories/recipe_space_repository.dart';
export 'src/repositories/user_recipe_prefs_repository.dart';
export 'src/snapshots/recipe_repository_snapshots.dart';
export 'src/snapshots/recipe_snapshot_copy.dart';
export 'src/text/plural.dart';
export 'src/value_objects/ids.dart';
export 'src/value_objects/nutrition_source.dart';
export 'src/value_objects/sort_key.dart';
