import 'package:data/src/change_log/entity_codec.dart';
import 'package:data/src/recipes/recipe_codecs.dart';
import 'package:domain/domain.dart';

/// One entity as JSON: its kind, id, and change log fields.
typedef EntityRecord = Map<String, Object?>;

/// Turns a whole [RecipeSnapshot] into JSON-compatible entity records and
/// back, using the same field encoding as the change log, so a recipe sent
/// to another app (a copy, PRD 7.10) reads exactly as it would if it had
/// synced.
///
/// Each record is `{entity, entityId, fields}`.
final class const RecipeSnapshotCodec() {
  static final _recipe = RecipeCodec();
  static final _ingredientSection = IngredientSectionCodec();
  static final _ingredientLine = IngredientLineCodec();
  static final _stepSection = StepSectionCodec();
  static final _step = RecipeStepCodec();

  /// Every entity in [snapshot], the recipe first.
  List<EntityRecord> encode(RecipeSnapshot snapshot) => [
    _record(_recipe, snapshot.recipe),
    for (final section in snapshot.ingredientSections)
      _record(_ingredientSection, section),
    for (final line in snapshot.ingredientLines) _record(_ingredientLine, line),
    for (final section in snapshot.stepSections) _record(_stepSection, section),
    for (final step in snapshot.steps) _record(_step, step),
  ];

  /// The snapshot [records] hold, or null without a valid recipe record.
  /// Records of other kinds, or that are incomplete, are skipped; lists are
  /// put in sort order.
  RecipeSnapshot? decode(List<Object?> records) {
    final byKind = <String, List<(String, Map<String, Object?>)>>{};
    for (final record in records) {
      if (record case {
        'entity': final String entity,
        'entityId': final String entityId,
        'fields': final Map<Object?, Object?> fields,
      }) {
        (byKind[entity] ??= []).add((entityId, fields.cast<String, Object?>()));
      }
    }
    List<T> decodeAll<T>(EntityCodec<T> codec) => [
      for (final (id, fields)
          in byKind[codec.entity] ?? const <(String, Map<String, Object?>)>[])
        ?codec.decode(id, fields),
    ];

    final recipe = decodeAll(_recipe).firstOrNull;
    if (recipe == null) return null;
    bool ownedBy(RecipeId recipeId) => recipeId == recipe.id;
    return RecipeSnapshot(
      recipe: recipe,
      ingredientSections:
          decodeAll(_ingredientSection)
              .where((s) => ownedBy(s.recipeId))
              .toList()
            ..sort((a, b) => a.sortKey.compareTo(b.sortKey.value)),
      ingredientLines:
          decodeAll(_ingredientLine).where((l) => ownedBy(l.recipeId)).toList()
            ..sort((a, b) => a.sortKey.compareTo(b.sortKey.value)),
      stepSections:
          decodeAll(_stepSection).where((s) => ownedBy(s.recipeId)).toList()
            ..sort((a, b) => a.sortKey.compareTo(b.sortKey.value)),
      steps: decodeAll(_step).where((s) => ownedBy(s.recipeId)).toList()
        ..sort((a, b) => a.sortKey.compareTo(b.sortKey.value)),
    );
  }

  static EntityRecord _record<T>(EntityCodec<T> codec, T value) => {
    'entity': codec.entity,
    'entityId': codec.idOf(value),
    'fields': codec.encode(value),
  };
}
