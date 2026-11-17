import 'package:clock/clock.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/bundled_foods.dart';
import 'package:sousvite/app/providers/database.dart';

part 'repositories.g.dart';

// One provider per repository interface in packages/domain. Features watch
// these and tests override them with fakes. Each data task replaces one
// body with its Drift implementation (docs/BUILD_PLAN.md).

@Riverpod(keepAlive: true)
AppSettingsRepository appSettingsRepository(Ref ref) =>
    DriftAppSettingsRepository(
      ref.watch(appDatabaseProvider),
      recorder: ref.watch(changeRecorderProvider).requireValue,
    );

@Riverpod(keepAlive: true)
RecipeRepository recipeRepository(Ref ref) => DriftRecipeRepository(
  ref.watch(appDatabaseProvider),
  recorder: ref.watch(changeRecorderProvider).requireValue,
);

@Riverpod(keepAlive: true)
RecipeSpaceRepository recipeSpaceRepository(Ref ref) =>
    DriftRecipeSpaceRepository(
      ref.watch(appDatabaseProvider),
      recorder: ref.watch(changeRecorderProvider).requireValue,
    );

@Riverpod(keepAlive: true)
FolderRepository folderRepository(Ref ref) => DriftFolderRepository(
  ref.watch(appDatabaseProvider),
  recorder: ref.watch(changeRecorderProvider).requireValue,
  now: clock.now,
);

@Riverpod(keepAlive: true)
FoodRepository foodRepository(Ref ref) => DriftFoodRepository(
  ref.watch(appDatabaseProvider),
  recorder: ref.watch(changeRecorderProvider).requireValue,
  bundled: ref.watch(bundledFoodsProvider).value,
);

@Riverpod(keepAlive: true)
ExperimentRepository experimentRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  final recorder = ref.watch(changeRecorderProvider).requireValue;
  return DriftExperimentRepository(
    database,
    recorder: recorder,
    recipes: DriftRecipeRepository(database, recorder: recorder),
    now: clock.now,
  );
}

@Riverpod(keepAlive: true)
GroceryRepository groceryRepository(Ref ref) => DriftGroceryRepository(
  ref.watch(appDatabaseProvider),
  recorder: ref.watch(changeRecorderProvider).requireValue,
);

@Riverpod(keepAlive: true)
MeasuringToolRepository measuringToolRepository(Ref ref) =>
    DriftMeasuringToolRepository(
      ref.watch(appDatabaseProvider),
      recorder: ref.watch(changeRecorderProvider).requireValue,
    );

@Riverpod(keepAlive: true)
UserRecipePrefsRepository userRecipePrefsRepository(Ref ref) =>
    DriftUserRecipePrefsRepository(
      ref.watch(appDatabaseProvider),
      recorder: ref.watch(changeRecorderProvider).requireValue,
    );
