import 'package:clock/clock.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/database.dart';

part 'repositories.g.dart';

// One provider per repository interface in packages/domain. Features watch
// these and tests override them with fakes. Each data task replaces one
// body with its Drift implementation (docs/BUILD_PLAN.md).

@Riverpod(keepAlive: true)
AppSettingsRepository appSettingsRepository(Ref ref) =>
    throw UnimplementedError('AppSettingsRepository is not implemented yet.');

@Riverpod(keepAlive: true)
RecipeRepository recipeRepository(Ref ref) => DriftRecipeRepository(
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
FoodRepository foodRepository(Ref ref) =>
    throw UnimplementedError('FoodRepository is not implemented yet.');

@Riverpod(keepAlive: true)
ExperimentRepository experimentRepository(Ref ref) =>
    throw UnimplementedError('ExperimentRepository is not implemented yet.');

@Riverpod(keepAlive: true)
GroceryRepository groceryRepository(Ref ref) => DriftGroceryRepository(
  ref.watch(appDatabaseProvider),
  recorder: ref.watch(changeRecorderProvider).requireValue,
);

@Riverpod(keepAlive: true)
MeasuringToolRepository measuringToolRepository(Ref ref) =>
    throw UnimplementedError('MeasuringToolRepository is not implemented yet.');

@Riverpod(keepAlive: true)
UserRecipePrefsRepository userRecipePrefsRepository(Ref ref) =>
    throw UnimplementedError(
      'UserRecipePrefsRepository is not implemented yet.',
    );
