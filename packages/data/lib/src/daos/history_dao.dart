import 'package:data/src/app_database.dart';
import 'package:data/src/tables/history_tables.dart';
import 'package:drift/drift.dart';

part 'history_dao.g.dart';

/// Queries for recipe versions and experiments.
///
/// Writes here record no changes: `DriftExperimentRepository` wraps them in
/// a `ChangeRecorder` write, and the sync appliers call them directly.
@DriftAccessor(tables: [RecipeVersions, Experiments])
class HistoryDao(super.attachedDatabase)
    extends DatabaseAccessor<AppDatabase>
    with _$HistoryDaoMixin {
  /// The versions of [recipeId], newest first.
  Selectable<RecipeVersionRow> versionsOf(String recipeId) =>
      select(recipeVersions)
        ..where((row) => row.recipeId.equals(recipeId))
        ..orderBy([
          (row) => OrderingTerm.desc(row.createdAt),
          (row) => OrderingTerm.asc(row.id),
        ]);

  /// The experiments on [recipeId], newest first.
  Selectable<ExperimentRow> experimentsOf(String recipeId) =>
      select(experiments)
        ..where((row) => row.recipeId.equals(recipeId))
        ..orderBy([
          (row) => OrderingTerm.desc(row.createdAt),
          (row) => OrderingTerm.asc(row.id),
        ]);

  /// The version with [id].
  Selectable<RecipeVersionRow> version(String id) =>
      select(recipeVersions)..where((row) => row.id.equals(id));

  /// The experiment with [id].
  Selectable<ExperimentRow> experiment(String id) =>
      select(experiments)..where((row) => row.id.equals(id));

  /// Inserts or replaces a version row.
  Future<void> upsertVersion(RecipeVersionsCompanion row) =>
      into(recipeVersions).insertOnConflictUpdate(row);

  /// Inserts or replaces an experiment row.
  Future<void> upsertExperiment(ExperimentsCompanion row) =>
      into(experiments).insertOnConflictUpdate(row);

  /// Deletes the version row with [id].
  Future<void> deleteVersion(String id) =>
      (delete(recipeVersions)..where((row) => row.id.equals(id))).go();

  /// Deletes the experiment row with [id].
  Future<void> deleteExperiment(String id) =>
      (delete(experiments)..where((row) => row.id.equals(id))).go();
}
