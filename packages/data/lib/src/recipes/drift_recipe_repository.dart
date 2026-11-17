import 'package:collection/collection.dart';
import 'package:data/src/app_database.dart';
import 'package:data/src/change_log/change_recorder.dart';
import 'package:data/src/change_log/change_set.dart';
import 'package:data/src/change_log/entity_applier.dart';
import 'package:data/src/change_log/materializing_applier.dart';
import 'package:data/src/daos/recipe_dao.dart';
import 'package:data/src/recipes/recipe_codecs.dart';
import 'package:data/src/recipes/recipe_rows.dart';
import 'package:data/src/recipes/recipe_search_query.dart';
import 'package:data/src/recipes/recipe_spaces.dart';
import 'package:domain/domain.dart';

/// [RecipeRepository] over the local database.
///
/// Every write goes through [recorder], so it lands in the change log in
/// the same transaction, recording only the fields that changed. Changes to
/// a recipe and its parts go to the recipe's space ([RecipeSpaces]), so
/// edits to a jointly shared recipe reach everyone in the share. Watch
/// streams skip values equal to the last one, so widgets rebuild only when
/// their data changes (ENGINEERING.md §5).
final class DriftRecipeRepository(
  /// The database the recipes and the change log live in.
  final AppDatabase database, {

  /// Records each write's changes for sync.
  required final ChangeRecorder recorder,
}) implements RecipeRepository {
  RecipeDao get _dao => database.recipeDao;

  late final _spaces = RecipeSpaces(database);

  static final _recipes = RecipeCodec();
  static final _ingredientSections = IngredientSectionCodec();
  static final _ingredientLines = IngredientLineCodec();
  static final _stepSections = StepSectionCodec();
  static final _steps = RecipeStepCodec();

  /// Writes remote changes for recipes and their parts, by entity kind,
  /// for `DriftLocalStore`.
  Map<String, EntityApplier> get appliers => {
    _recipes.entity: MaterializingApplier(
      database,
      codec: _recipes,
      write: (recipe) => _dao.upsert(_dao.recipes, recipe.toCompanion()),
      remove: _dao.deleteRecipe,
    ),
    _ingredientSections.entity: MaterializingApplier(
      database,
      codec: _ingredientSections,
      write: (section) =>
          _dao.upsert(_dao.ingredientSections, section.toCompanion()),
      remove: _dao.deleteIngredientSection,
    ),
    _ingredientLines.entity: MaterializingApplier(
      database,
      codec: _ingredientLines,
      write: (line) => _dao.upsert(_dao.ingredientLines, line.toCompanion()),
      remove: _dao.deleteIngredientLine,
    ),
    _stepSections.entity: MaterializingApplier(
      database,
      codec: _stepSections,
      write: (section) => _dao.upsert(_dao.stepSections, section.toCompanion()),
      remove: _dao.deleteStepSection,
    ),
    _steps.entity: MaterializingApplier(
      database,
      codec: _steps,
      write: (step) => _dao.upsert(_dao.recipeSteps, step.toCompanion()),
      remove: _dao.deleteStep,
    ),
  };

  // Reads.

  @override
  Stream<List<RecipeId>> watchRecipeIds() => _dao
      .watchRecipeIds()
      .map((ids) => [for (final id in ids) RecipeId(id)])
      .distinct(_listEquals);

  @override
  Stream<List<RecipeId>> watchSearch(String query) {
    final match = recipeSearchMatch(query);
    if (match == null) return watchRecipeIds();
    return _dao
        .watchSearch(match)
        .map((ids) => [for (final id in ids) RecipeId(id)])
        .distinct(_listEquals);
  }

  @override
  Stream<Recipe?> watchRecipe(RecipeId id) => _dao
      .recipe(id.value)
      .watchSingleOrNull()
      .map((row) => row?.toEntity())
      .distinct();

  @override
  Stream<List<IngredientSection>> watchIngredientSections(RecipeId recipeId) =>
      _dao
          .ingredientSectionsOf(recipeId.value)
          .watch()
          .map((rows) => [for (final row in rows) row.toEntity()])
          .distinct(_listEquals);

  @override
  Stream<List<IngredientLine>> watchIngredientLines(RecipeId recipeId) => _dao
      .ingredientLinesOf(recipeId.value)
      .watch()
      .map((rows) => [for (final row in rows) row.toEntity()])
      .distinct(_listEquals);

  @override
  Stream<List<StepSection>> watchStepSections(RecipeId recipeId) => _dao
      .stepSectionsOf(recipeId.value)
      .watch()
      .map((rows) => [for (final row in rows) row.toEntity()])
      .distinct(_listEquals);

  @override
  Stream<List<RecipeStep>> watchSteps(RecipeId recipeId) => _dao
      .stepsOf(recipeId.value)
      .watch()
      .map((rows) => [for (final row in rows) row.toEntity()])
      .distinct(_listEquals);

  @override
  Future<Recipe?> getRecipe(RecipeId id) async =>
      (await _dao.recipe(id.value).getSingleOrNull())?.toEntity();

  /// The recipe [id] with every part, in sort order, or null when it does
  /// not exist. Used to save versions and start experiments.
  Future<RecipeSnapshot?> getSnapshot(RecipeId id) async {
    final recipe = await getRecipe(id);
    if (recipe == null) return null;
    final recipeId = id.value;
    return RecipeSnapshot(
      recipe: recipe,
      ingredientSections: [
        for (final row in await _dao.ingredientSectionsOf(recipeId).get())
          row.toEntity(),
      ],
      ingredientLines: [
        for (final row in await _dao.ingredientLinesOf(recipeId).get())
          row.toEntity(),
      ],
      stepSections: [
        for (final row in await _dao.stepSectionsOf(recipeId).get())
          row.toEntity(),
      ],
      steps: [
        for (final row in await _dao.stepsOf(recipeId).get()) row.toEntity(),
      ],
    );
  }

  /// Makes the recipe in [contents] hold exactly its parts: parts not in
  /// it are deleted and the rest saved, in one transaction. The recipe's
  /// fields come from `contents.recipe`. Used by restore and promote.
  Future<void> replaceContents(RecipeSnapshot contents) =>
      recorder.write((changes) async {
        final current = await getSnapshot(contents.recipe.id);
        if (current != null) {
          final keep = <String>{
            for (final part in contents.ingredientSections) part.id.value,
            for (final part in contents.ingredientLines) part.id.value,
            for (final part in contents.stepSections) part.id.value,
            for (final part in contents.steps) part.id.value,
          };
          for (final line in current.ingredientLines) {
            if (!keep.contains(line.id.value)) {
              await _deleteIngredientLine(changes, line.id.value);
            }
          }
          for (final section in current.ingredientSections) {
            if (!keep.contains(section.id.value)) {
              await _deleteIngredientSection(changes, section.id.value);
            }
          }
          for (final step in current.steps) {
            if (!keep.contains(step.id.value)) {
              await _deleteStep(changes, step.id.value);
            }
          }
          for (final section in current.stepSections) {
            if (!keep.contains(section.id.value)) {
              await _deleteStepSection(changes, section.id.value);
            }
          }
        }
        await _saveSnapshot(changes, contents);
      });

  // Writes.

  @override
  Future<void> saveRecipe(Recipe recipe) =>
      recorder.write((changes) => _saveRecipe(changes, recipe));

  @override
  Future<void> saveIngredientSection(IngredientSection section) =>
      recorder.write((changes) => _saveIngredientSection(changes, section));

  @override
  Future<void> saveIngredientLine(IngredientLine line) =>
      recorder.write((changes) => _saveIngredientLine(changes, line));

  @override
  Future<void> saveStepSection(StepSection section) =>
      recorder.write((changes) => _saveStepSection(changes, section));

  @override
  Future<void> saveStep(RecipeStep step) =>
      recorder.write((changes) => _saveStep(changes, step));

  @override
  Future<void> saveSnapshot(RecipeSnapshot snapshot) =>
      recorder.write((changes) => _saveSnapshot(changes, snapshot));

  /// Deleting a jointly shared recipe deletes only the user's copy: it
  /// moves back to the user's own library first, so the delete stays out
  /// of the share and the others keep the recipe (PRD 7.10).
  @override
  Future<void> deleteRecipe(RecipeId id) => recorder.write((changes) async {
    final recipeId = id.value;
    await _takeOutOfSharedSpace(recipeId);
    for (final row in await _dao.ingredientLinesOf(recipeId).get()) {
      await _deleteIngredientLine(changes, row.id);
    }
    for (final row in await _dao.ingredientSectionsOf(recipeId).get()) {
      await _deleteIngredientSection(changes, row.id);
    }
    for (final row in await _dao.stepsOf(recipeId).get()) {
      await _deleteStep(changes, row.id);
    }
    for (final row in await _dao.stepSectionsOf(recipeId).get()) {
      await _deleteStepSection(changes, row.id);
    }
    await _dao.deleteRecipe(recipeId);
    changes.delete(
      _recipes.entity,
      recipeId,
      spaceId: await _spaces.sharedSpaceOf(recipeId),
    );
  });

  /// Deletes the section with the lines in it, as the editor does.
  @override
  Future<void> deleteIngredientSection(
    IngredientSectionId id,
  ) => recorder.write((changes) async {
    final section = await _dao.ingredientSection(id.value).getSingleOrNull();
    if (section == null) return;
    for (final line in await _dao.ingredientLinesOf(section.recipeId).get()) {
      if (line.sectionId == id.value) {
        await _deleteIngredientLine(changes, line.id);
      }
    }
    await _deleteIngredientSection(changes, id.value);
  });

  @override
  Future<void> deleteIngredientLine(IngredientLineId id) =>
      recorder.write((changes) => _deleteIngredientLine(changes, id.value));

  /// Deletes the section with the steps in it, as the editor does.
  @override
  Future<void> deleteStepSection(StepSectionId id) =>
      recorder.write((changes) async {
        final section = await _dao.stepSection(id.value).getSingleOrNull();
        if (section == null) return;
        for (final step in await _dao.stepsOf(section.recipeId).get()) {
          if (step.sectionId == id.value) await _deleteStep(changes, step.id);
        }
        await _deleteStepSection(changes, id.value);
      });

  @override
  Future<void> deleteStep(RecipeStepId id) =>
      recorder.write((changes) => _deleteStep(changes, id.value));

  // One entity at a time, inside a write.

  Future<void> _saveSnapshot(ChangeSet changes, RecipeSnapshot snapshot) async {
    await _saveRecipe(changes, snapshot.recipe);
    for (final section in snapshot.ingredientSections) {
      await _saveIngredientSection(changes, section);
    }
    for (final line in snapshot.ingredientLines) {
      await _saveIngredientLine(changes, line);
    }
    for (final section in snapshot.stepSections) {
      await _saveStepSection(changes, section);
    }
    for (final step in snapshot.steps) {
      await _saveStep(changes, step);
    }
  }

  Future<void> _saveRecipe(ChangeSet changes, Recipe recipe) async {
    final before = await _dao.recipe(recipe.id.value).getSingleOrNull();
    changes.setChanged(
      _recipes,
      recipe,
      before: before?.toEntity(),
      spaceId: await _spaces.sharedSpaceOf(recipe.id.value),
    );
    await _dao.upsert(_dao.recipes, recipe.toCompanion());
  }

  Future<void> _saveIngredientSection(
    ChangeSet changes,
    IngredientSection section,
  ) async {
    final before = await _dao
        .ingredientSection(section.id.value)
        .getSingleOrNull();
    changes.setChanged(
      _ingredientSections,
      section,
      before: before?.toEntity(),
      spaceId: await _spaces.sharedSpaceOf(section.recipeId.value),
    );
    await _dao.upsert(_dao.ingredientSections, section.toCompanion());
  }

  Future<void> _saveIngredientLine(
    ChangeSet changes,
    IngredientLine line,
  ) async {
    final before = await _dao.ingredientLine(line.id.value).getSingleOrNull();
    changes.setChanged(
      _ingredientLines,
      line,
      before: before?.toEntity(),
      spaceId: await _spaces.sharedSpaceOf(line.recipeId.value),
    );
    await _dao.upsert(_dao.ingredientLines, line.toCompanion());
  }

  Future<void> _saveStepSection(ChangeSet changes, StepSection section) async {
    final before = await _dao.stepSection(section.id.value).getSingleOrNull();
    changes.setChanged(
      _stepSections,
      section,
      before: before?.toEntity(),
      spaceId: await _spaces.sharedSpaceOf(section.recipeId.value),
    );
    await _dao.upsert(_dao.stepSections, section.toCompanion());
  }

  Future<void> _saveStep(ChangeSet changes, RecipeStep step) async {
    final before = await _dao.step(step.id.value).getSingleOrNull();
    changes.setChanged(
      _steps,
      step,
      before: before?.toEntity(),
      spaceId: await _spaces.sharedSpaceOf(step.recipeId.value),
    );
    await _dao.upsert(_dao.recipeSteps, step.toCompanion());
  }

  Future<void> _deleteIngredientSection(ChangeSet changes, String id) async {
    final row = await _dao.ingredientSection(id).getSingleOrNull();
    await _dao.deleteIngredientSection(id);
    changes.delete(
      _ingredientSections.entity,
      id,
      spaceId: await _spaceOfPart(row?.recipeId),
    );
  }

  Future<void> _deleteIngredientLine(ChangeSet changes, String id) async {
    final row = await _dao.ingredientLine(id).getSingleOrNull();
    await _dao.deleteIngredientLine(id);
    changes.delete(
      _ingredientLines.entity,
      id,
      spaceId: await _spaceOfPart(row?.recipeId),
    );
  }

  Future<void> _deleteStepSection(ChangeSet changes, String id) async {
    final row = await _dao.stepSection(id).getSingleOrNull();
    await _dao.deleteStepSection(id);
    changes.delete(
      _stepSections.entity,
      id,
      spaceId: await _spaceOfPart(row?.recipeId),
    );
  }

  Future<void> _deleteStep(ChangeSet changes, String id) async {
    final row = await _dao.step(id).getSingleOrNull();
    await _dao.deleteStep(id);
    changes.delete(
      _steps.entity,
      id,
      spaceId: await _spaceOfPart(row?.recipeId),
    );
  }

  /// Records that [recipeId] is in the user's own library, in its own
  /// write so that every change after it is routed there too.
  Future<void> _takeOutOfSharedSpace(String recipeId) async {
    if (await _spaces.sharedSpaceOf(recipeId) == null) return;
    await recorder.write(
      (changes) async =>
          changes.set(_recipes.entity, recipeId, {RecipeSpaces.field: null}),
    );
  }

  /// The space of a part's recipe, or the user's own library when the part
  /// is already gone.
  Future<String?> _spaceOfPart(String? recipeId) async =>
      recipeId == null ? null : await _spaces.sharedSpaceOf(recipeId);

  static bool _listEquals<T>(List<T> a, List<T> b) =>
      const ListEquality<Object?>().equals(a, b);
}
