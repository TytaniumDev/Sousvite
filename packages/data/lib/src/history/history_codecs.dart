import 'package:data/src/change_log/entity_codec.dart';
import 'package:data/src/change_log/field_values.dart';
import 'package:domain/domain.dart';

/// [RecipeVersion] fields in the change log.
final class RecipeVersionCodec() implements EntityCodec<RecipeVersion> {
  @override
  String get entity => 'recipe_version';

  @override
  String idOf(RecipeVersion value) => value.id.value;

  @override
  Map<String, Object?> encode(RecipeVersion value) => {
    'recipeId': value.recipeId.value,
    'createdAt': encodeDateTime(value.createdAt),
    'snapshotJson': value.snapshotJson,
    'summary': value.summary,
  };

  @override
  RecipeVersion? decode(String id, Map<String, Object?> fields) {
    final createdAt = decodeDateTime(fields['createdAt']);
    if (fields
        case {
          'recipeId': final String recipeId,
          'snapshotJson': final String snapshotJson,
        }
        when createdAt != null) {
      return RecipeVersion(
        id: RecipeVersionId(id),
        recipeId: RecipeId(recipeId),
        createdAt: createdAt,
        snapshotJson: snapshotJson,
        summary: fields['summary'] as String? ?? '',
      );
    }
    return null;
  }
}

/// [Experiment] fields in the change log.
final class ExperimentCodec() implements EntityCodec<Experiment> {
  @override
  String get entity => 'experiment';

  @override
  String idOf(Experiment value) => value.id.value;

  @override
  Map<String, Object?> encode(Experiment value) => {
    'recipeId': value.recipeId.value,
    'baseVersionId': value.baseVersionId.value,
    'workingRecipeId': value.workingRecipeId.value,
    'createdAt': encodeDateTime(value.createdAt),
    'changeDescription': value.changeDescription,
    'notes': value.notes,
    'sharedWithOthers': value.sharedWithOthers,
    'outcome': encodeEnum(value.outcome),
  };

  @override
  Experiment? decode(String id, Map<String, Object?> fields) {
    final createdAt = decodeDateTime(fields['createdAt']);
    if (fields
        case {
          'recipeId': final String recipeId,
          'baseVersionId': final String baseVersionId,
          'workingRecipeId': final String workingRecipeId,
        }
        when createdAt != null) {
      return Experiment(
        id: ExperimentId(id),
        recipeId: RecipeId(recipeId),
        baseVersionId: RecipeVersionId(baseVersionId),
        workingRecipeId: RecipeId(workingRecipeId),
        createdAt: createdAt,
        changeDescription: fields['changeDescription'] as String? ?? '',
        notes: fields['notes'] as String? ?? '',
        sharedWithOthers: fields['sharedWithOthers'] as bool? ?? false,
        outcome:
            decodeEnum(ExperimentOutcome.values, fields['outcome']) ??
            ExperimentOutcome.open,
      );
    }
    return null;
  }
}
