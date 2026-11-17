import 'package:data/src/app_database.dart';
import 'package:data/src/change_log/change_recorder.dart';
import 'package:data/src/change_log/entity_codec.dart';
import 'package:data/src/recipes/recipe_codecs.dart';
import 'package:data/src/recipes/recipe_rows.dart';
import 'package:data/src/recipes/recipe_spaces.dart';
import 'package:domain/domain.dart';

/// [RecipeSpaceRepository] over the local database.
///
/// Moving a recipe records every field of it and its parts again in the
/// new space, then the recipe's space ([RecipeSpaces.field]) in the space
/// that should see the move. So the new space gets the whole recipe, and
/// from then on `DriftRecipeRepository` sends each edit there.
final class DriftRecipeSpaceRepository(
  /// The database the recipes and the change log live in.
  final AppDatabase database, {

  /// Records each move for sync.
  required final ChangeRecorder recorder,
}) implements RecipeSpaceRepository {
  late final _spaces = RecipeSpaces(database);

  static final _recipes = RecipeCodec();
  static final _ingredientSections = IngredientSectionCodec();
  static final _ingredientLines = IngredientLineCodec();
  static final _stepSections = StepSectionCodec();
  static final _steps = RecipeStepCodec();

  @override
  Stream<String?> watchSharedSpace(RecipeId recipeId) =>
      _spaces.watchSharedSpaceOf(recipeId.value);

  @override
  Future<String?> sharedSpaceOf(RecipeId recipeId) =>
      _spaces.sharedSpaceOf(recipeId.value);

  @override
  Future<List<RecipeId>> recipesInSharedSpace(String spaceId) async => [
    for (final id in await _spaces.recipesIn(spaceId)) RecipeId(id),
  ];

  // The move is recorded in the new space, so everyone in the share learns
  // the recipe is theirs too.
  @override
  Future<void> moveToSharedSpace(RecipeId recipeId, String spaceId) =>
      _move(recipeId, spaceId);

  // The move is recorded in the user's own library only, so the others in
  // the share keep the recipe where it is.
  @override
  Future<void> moveToOwnLibrary(RecipeId recipeId) => _move(recipeId, null);

  /// Records [recipeId] and its parts in [spaceId] (null for the user's
  /// own library), then the move itself. Does nothing when the recipe is
  /// gone or already there.
  Future<void> _move(RecipeId recipeId, String? spaceId) =>
      recorder.write((changes) async {
        final id = recipeId.value;
        final dao = database.recipeDao;
        final recipe = await dao.recipe(id).getSingleOrNull();
        if (recipe == null) return;
        if (await _spaces.sharedSpaceOf(id) == spaceId) return;

        void record<T>(EntityCodec<T> codec, T entity) => changes.set(
          codec.entity,
          codec.idOf(entity),
          codec.encode(entity),
          spaceId: spaceId,
        );
        record(_recipes, recipe.toEntity());
        for (final row in await dao.ingredientSectionsOf(id).get()) {
          record(_ingredientSections, row.toEntity());
        }
        for (final row in await dao.ingredientLinesOf(id).get()) {
          record(_ingredientLines, row.toEntity());
        }
        for (final row in await dao.stepSectionsOf(id).get()) {
          record(_stepSections, row.toEntity());
        }
        for (final row in await dao.stepsOf(id).get()) {
          record(_steps, row.toEntity());
        }
        changes.set(_recipes.entity, id, {
          RecipeSpaces.field: spaceId,
        }, spaceId: spaceId);
      });
}
