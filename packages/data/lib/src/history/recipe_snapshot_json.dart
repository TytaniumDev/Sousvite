import 'dart:convert';

import 'package:data/src/change_log/entity_codec.dart';
import 'package:data/src/recipes/recipe_codecs.dart';
import 'package:domain/domain.dart';

/// Writes a [RecipeSnapshot] as the JSON a [RecipeVersion] stores, and
/// reads it back.
///
/// Each part is its change log fields plus `id`, so a version reads the
/// same way a synced recipe does.
abstract final class RecipeSnapshotJson() {
  static final _recipe = RecipeCodec();
  static final _ingredientSections = IngredientSectionCodec();
  static final _ingredientLines = IngredientLineCodec();
  static final _stepSections = StepSectionCodec();
  static final _steps = RecipeStepCodec();

  /// [snapshot] as JSON text.
  static String encode(RecipeSnapshot snapshot) => jsonEncode({
    'recipe': _part(_recipe, snapshot.recipe),
    'ingredientSections': _parts(
      _ingredientSections,
      snapshot.ingredientSections,
    ),
    'ingredientLines': _parts(_ingredientLines, snapshot.ingredientLines),
    'stepSections': _parts(_stepSections, snapshot.stepSections),
    'steps': _parts(_steps, snapshot.steps),
  });

  /// The snapshot in [json], or null when it is not one [encode] wrote.
  static RecipeSnapshot? decode(String json) {
    final Object? data;
    try {
      data = jsonDecode(json);
    } on FormatException {
      return null;
    }
    if (data is! Map<String, Object?>) return null;
    final recipe = _decode(_recipe, data['recipe']);
    if (recipe == null) return null;
    return RecipeSnapshot(
      recipe: recipe,
      ingredientSections: _decodeAll(
        _ingredientSections,
        data['ingredientSections'],
      ),
      ingredientLines: _decodeAll(_ingredientLines, data['ingredientLines']),
      stepSections: _decodeAll(_stepSections, data['stepSections']),
      steps: _decodeAll(_steps, data['steps']),
    );
  }

  static Map<String, Object?> _part<T>(EntityCodec<T> codec, T value) => {
    'id': codec.idOf(value),
    ...codec.encode(value),
  };

  static List<Map<String, Object?>> _parts<T>(
    EntityCodec<T> codec,
    List<T> values,
  ) => [for (final value in values) _part(codec, value)];

  static T? _decode<T>(EntityCodec<T> codec, Object? part) => switch (part) {
    {'id': final String id} => codec.decode(id, part as Map<String, Object?>),
    _ => null,
  };

  static List<T> _decodeAll<T>(EntityCodec<T> codec, Object? parts) => [
    if (parts is List)
      for (final part in parts) ?_decode(codec, part),
  ];
}
