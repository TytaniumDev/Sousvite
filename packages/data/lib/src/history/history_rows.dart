import 'package:data/src/app_database.dart';
import 'package:domain/domain.dart';
import 'package:drift/drift.dart';

/// Reads a [RecipeVersion] from its row.
extension RecipeVersionRowMapping on RecipeVersionRow {
  /// The entity this row stores.
  RecipeVersion toEntity() => RecipeVersion(
    id: RecipeVersionId(id),
    recipeId: RecipeId(recipeId),
    createdAt: createdAt,
    snapshotJson: snapshotJson,
    summary: summary,
  );
}

/// Writes a [RecipeVersion] as a row.
extension RecipeVersionCompanionMapping on RecipeVersion {
  /// A row with every column set, the time in UTC.
  RecipeVersionsCompanion toCompanion() => RecipeVersionsCompanion.insert(
    id: id.value,
    recipeId: recipeId.value,
    createdAt: createdAt.toUtc(),
    snapshotJson: snapshotJson,
    summary: Value(summary),
  );
}

/// Reads an [Experiment] from its row.
extension ExperimentRowMapping on ExperimentRow {
  /// The entity this row stores.
  Experiment toEntity() => Experiment(
    id: ExperimentId(id),
    recipeId: RecipeId(recipeId),
    baseVersionId: RecipeVersionId(baseVersionId),
    workingRecipeId: RecipeId(workingRecipeId),
    createdAt: createdAt,
    changeDescription: changeDescription,
    notes: notes,
    sharedWithOthers: sharedWithOthers,
    outcome: outcome,
  );
}

/// Writes an [Experiment] as a row.
extension ExperimentCompanionMapping on Experiment {
  /// A row with every column set, the time in UTC.
  ExperimentsCompanion toCompanion() => ExperimentsCompanion.insert(
    id: id.value,
    recipeId: recipeId.value,
    baseVersionId: baseVersionId.value,
    workingRecipeId: workingRecipeId.value,
    createdAt: createdAt.toUtc(),
    changeDescription: Value(changeDescription),
    notes: Value(notes),
    sharedWithOthers: Value(sharedWithOthers),
    outcome: outcome,
  );
}
