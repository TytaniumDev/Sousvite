import 'package:collection/collection.dart';
import 'package:data/src/app_database.dart';
import 'package:data/src/change_log/change_recorder.dart';
import 'package:data/src/change_log/change_set.dart';
import 'package:data/src/change_log/entity_applier.dart';
import 'package:data/src/change_log/materializing_applier.dart';
import 'package:data/src/daos/history_dao.dart';
import 'package:data/src/history/history_codecs.dart';
import 'package:data/src/history/history_rows.dart';
import 'package:data/src/history/recipe_snapshot_json.dart';
import 'package:data/src/recipes/drift_recipe_repository.dart';
import 'package:data/src/recipes/recipe_codecs.dart';
import 'package:domain/domain.dart';
import 'package:sync/sync.dart';

/// [ExperimentRepository] over the local database: a recipe's versions and
/// experiments (PRD 7.11).
///
/// Start, promote, and restore each run in one transaction, writing the
/// recipe through [recipes] so its changes are recorded like any edit.
final class DriftExperimentRepository(
  /// The database the history and the change log live in.
  final AppDatabase database, {

  /// Records each write's changes for sync.
  required final ChangeRecorder recorder,

  /// The recipes whose history this is.
  required final DriftRecipeRepository recipes,

  /// Reads the wall clock, for new versions and experiments.
  final DateTime Function() now = DateTime.now,
}) implements ExperimentRepository {
  HistoryDao get _dao => database.historyDao;

  /// The current time in UTC, as the database returns it.
  DateTime _now() => now().toUtc();

  static final _versions = RecipeVersionCodec();
  static final _experiments = ExperimentCodec();
  static final _recipeCodec = RecipeCodec();
  static final _stepCodec = RecipeStepCodec();

  /// Writes remote changes for versions and experiments, by entity kind,
  /// for `DriftLocalStore`.
  Map<String, EntityApplier> get appliers => {
    _versions.entity: MaterializingApplier(
      database,
      codec: _versions,
      write: (version) => _dao.upsertVersion(version.toCompanion()),
      remove: _dao.deleteVersion,
    ),
    _experiments.entity: MaterializingApplier(
      database,
      codec: _experiments,
      write: (experiment) => _dao.upsertExperiment(experiment.toCompanion()),
      remove: _dao.deleteExperiment,
    ),
  };

  // Reads.

  @override
  Stream<List<RecipeVersion>> watchVersions(RecipeId recipeId) => _dao
      .versionsOf(recipeId.value)
      .watch()
      .map((rows) => [for (final row in rows) row.toEntity()])
      .distinct(const ListEquality<RecipeVersion>().equals);

  @override
  Stream<List<Experiment>> watchExperiments(RecipeId recipeId) => _dao
      .experimentsOf(recipeId.value)
      .watch()
      .map((rows) => [for (final row in rows) row.toEntity()])
      .distinct(const ListEquality<Experiment>().equals);

  @override
  Future<RecipeVersion?> getVersion(RecipeVersionId id) async =>
      (await _dao.version(id.value).getSingleOrNull())?.toEntity();

  @override
  Future<Experiment?> getExperiment(ExperimentId id) async =>
      (await _dao.experiment(id.value).getSingleOrNull())?.toEntity();

  @override
  Future<RecipeSnapshot?> getVersionSnapshot(RecipeVersionId id) async {
    final version = await getVersion(id);
    return version == null
        ? null
        : RecipeSnapshotJson.decode(version.snapshotJson);
  }

  // Writes.

  @override
  Future<void> saveVersion(RecipeVersion version) =>
      recorder.write((changes) => _saveVersion(changes, version));

  @override
  Future<void> saveExperiment(Experiment experiment) =>
      recorder.write((changes) => _saveExperiment(changes, experiment));

  /// Deletes the experiment and its working copy of the recipe.
  @override
  Future<void> deleteExperiment(ExperimentId id) =>
      recorder.write((changes) async {
        final experiment = await getExperiment(id);
        if (experiment == null) return;
        await recipes.deleteRecipe(experiment.workingRecipeId);
        await _dao.deleteExperiment(id.value);
        changes.delete(_experiments.entity, id.value);
      });

  @override
  Future<Experiment> startExperiment(RecipeId recipeId) =>
      recorder.write((changes) async {
        final current = await _requireSnapshot(recipeId);
        final base = await _saveCurrent(changes, current);
        final time = _now();
        final workingId = RecipeId(recorder.newId());
        final working = current.copyAs(workingId, newId: recorder.newId);
        await recipes.saveSnapshot(
          working.copyWith(
            recipe: working.recipe.copyWith(createdAt: time, updatedAt: time),
          ),
        );
        final experiment = Experiment(
          id: ExperimentId(recorder.newId()),
          recipeId: recipeId,
          baseVersionId: base.id,
          workingRecipeId: workingId,
          createdAt: time,
        );
        await _saveExperiment(changes, experiment);
        return experiment;
      });

  @override
  Future<void> promoteExperiment(ExperimentId id) => recorder.write((
    changes,
  ) async {
    final experiment = await getExperiment(id);
    if (experiment == null) return;
    final current = await _requireSnapshot(experiment.recipeId);
    final working = await _requireSnapshot(experiment.workingRecipeId);
    await _saveCurrent(changes, current);
    final contents = working.copyAs(experiment.recipeId, newId: recorder.newId);
    await recipes.replaceContents(
      contents.copyWith(
        recipe: contents.recipe.copyWith(
          createdAt: current.recipe.createdAt,
          updatedAt: _now(),
        ),
      ),
    );
    await _saveExperiment(
      changes,
      experiment.copyWith(outcome: ExperimentOutcome.adopted),
    );
  });

  @override
  Future<void> restoreVersion(RecipeVersionId id) =>
      recorder.write((changes) async {
        final version = await getVersion(id);
        final restored = version == null
            ? null
            : RecipeSnapshotJson.decode(version.snapshotJson);
        if (restored == null) return;
        final current = await recipes.getSnapshot(restored.recipe.id);
        if (current != null) await _saveCurrent(changes, current);
        await recipes.replaceContents(
          restored.copyWith(
            recipe: restored.recipe.copyWith(
              createdAt: current?.recipe.createdAt ?? restored.recipe.createdAt,
              updatedAt: _now(),
            ),
          ),
        );
      });

  /// Keeps edits that lost a sync merge on a long text field (a recipe's
  /// notes or a step's text) as versions of their recipe, so they can be
  /// recovered from history (ENGINEERING.md §8.1). Give it to
  /// `DriftLocalStore.onPreserved`.
  ///
  /// Each version's id comes from the losing change, so devices that keep
  /// the same edit write the same version.
  Future<void> preserveLosingEdits(List<Change> preserved) =>
      recorder.write((changes) async {
        for (final change in preserved) {
          final snapshot = await _withLosingEdit(change);
          if (snapshot == null) continue;
          await _saveVersion(
            changes,
            RecipeVersion(
              id: RecipeVersionId('preserved-${change.id}'),
              recipeId: snapshot.recipe.id,
              createdAt: _now(),
              snapshotJson: RecipeSnapshotJson.encode(snapshot),
            ),
          );
        }
      });

  // Inside a write.

  Future<RecipeSnapshot> _requireSnapshot(RecipeId recipeId) async =>
      await recipes.getSnapshot(recipeId) ??
      (throw StateError('Recipe ${recipeId.value} does not exist.'));

  /// Saves [current] as a new version and returns it.
  Future<RecipeVersion> _saveCurrent(
    ChangeSet changes,
    RecipeSnapshot current,
  ) async {
    final version = RecipeVersion(
      id: RecipeVersionId(recorder.newId()),
      recipeId: current.recipe.id,
      createdAt: _now(),
      snapshotJson: RecipeSnapshotJson.encode(current),
    );
    await _saveVersion(changes, version);
    return version;
  }

  Future<void> _saveVersion(ChangeSet changes, RecipeVersion version) async {
    final before = await _dao.version(version.id.value).getSingleOrNull();
    changes.setChanged(_versions, version, before: before?.toEntity());
    await _dao.upsertVersion(version.toCompanion());
  }

  Future<void> _saveExperiment(ChangeSet changes, Experiment experiment) async {
    final before = await _dao.experiment(experiment.id.value).getSingleOrNull();
    changes.setChanged(_experiments, experiment, before: before?.toEntity());
    await _dao.upsertExperiment(experiment.toCompanion());
  }

  /// The current recipe that [change] lost on, with the losing value put
  /// back, or null when it is not a recipe or step field or the recipe is
  /// gone.
  Future<RecipeSnapshot?> _withLosingEdit(Change change) async {
    if (change.entity == _recipeCodec.entity) {
      final snapshot = await recipes.getSnapshot(RecipeId(change.entityId));
      if (snapshot == null) return null;
      final recipe = _recipeCodec.decode(change.entityId, {
        ..._recipeCodec.encode(snapshot.recipe),
        change.field: change.value,
      });
      return recipe == null ? null : snapshot.copyWith(recipe: recipe);
    }
    if (change.entity == _stepCodec.entity) {
      final step = await database.recipeDao
          .step(change.entityId)
          .getSingleOrNull();
      if (step == null) return null;
      final snapshot = await recipes.getSnapshot(RecipeId(step.recipeId));
      if (snapshot == null) return null;
      return snapshot.copyWith(
        steps: [
          for (final current in snapshot.steps)
            if (current.id.value == change.entityId)
              _stepCodec.decode(change.entityId, {
                    ..._stepCodec.encode(current),
                    change.field: change.value,
                  }) ??
                  current
            else
              current,
        ],
      );
    }
    return null;
  }
}
