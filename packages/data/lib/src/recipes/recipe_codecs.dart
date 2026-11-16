import 'package:data/src/change_log/entity_codec.dart';
import 'package:data/src/change_log/field_values.dart';
import 'package:domain/domain.dart';

/// [Recipe] fields in the change log.
final class RecipeCodec() implements EntityCodec<Recipe> {
  @override
  String get entity => 'recipe';

  @override
  String idOf(Recipe value) => value.id.value;

  @override
  Map<String, Object?> encode(Recipe value) => {
    'title': value.title,
    'servings': encodeQuantity(value.servings),
    'createdAt': encodeDateTime(value.createdAt),
    'updatedAt': encodeDateTime(value.updatedAt),
    'photoRef': value.photoRef,
    'prepTime': encodeDuration(value.prepTime),
    'cookTime': encodeDuration(value.cookTime),
    'totalTime': encodeDuration(value.totalTime),
    'notes': value.notes,
    'sourceUrl': value.sourceUrl,
    'sourceName': value.sourceName,
  };

  @override
  Recipe? decode(String id, Map<String, Object?> fields) {
    final title = fields['title'];
    final servings = decodeQuantity(fields['servings']);
    final createdAt = decodeDateTime(fields['createdAt']);
    final updatedAt = decodeDateTime(fields['updatedAt']);
    if (title is! String ||
        servings == null ||
        createdAt == null ||
        updatedAt == null) {
      return null;
    }
    return Recipe(
      id: RecipeId(id),
      title: title,
      servings: servings,
      createdAt: createdAt,
      updatedAt: updatedAt,
      photoRef: fields['photoRef'] as String?,
      prepTime: decodeDuration(fields['prepTime']),
      cookTime: decodeDuration(fields['cookTime']),
      totalTime: decodeDuration(fields['totalTime']),
      notes: fields['notes'] as String? ?? '',
      sourceUrl: fields['sourceUrl'] as String?,
      sourceName: fields['sourceName'] as String?,
    );
  }
}

/// [IngredientSection] fields in the change log.
final class IngredientSectionCodec() implements EntityCodec<IngredientSection> {
  @override
  String get entity => 'ingredient_section';

  @override
  String idOf(IngredientSection value) => value.id.value;

  @override
  Map<String, Object?> encode(IngredientSection value) => {
    'recipeId': value.recipeId.value,
    'name': value.name,
    'sortKey': value.sortKey.value,
  };

  @override
  IngredientSection? decode(String id, Map<String, Object?> fields) =>
      switch (fields) {
        {
          'recipeId': final String recipeId,
          'name': final String name,
          'sortKey': final String sortKey,
        } =>
          IngredientSection(
            id: IngredientSectionId(id),
            recipeId: RecipeId(recipeId),
            name: name,
            sortKey: SortKey(sortKey),
          ),
        _ => null,
      };
}

/// [IngredientLine] fields in the change log.
final class IngredientLineCodec() implements EntityCodec<IngredientLine> {
  @override
  String get entity => 'ingredient_line';

  @override
  String idOf(IngredientLine value) => value.id.value;

  @override
  Map<String, Object?> encode(IngredientLine value) => {
    'recipeId': value.recipeId.value,
    'rawText': value.rawText,
    'sortKey': value.sortKey.value,
    'sectionId': value.sectionId?.value,
    'quantity': encodeQuantity(value.quantity),
    'quantityMax': encodeQuantity(value.quantityMax),
    'unit': encodeEnum(value.unit),
    'countWord': value.countWord,
    'name': value.name,
    'preparation': value.preparation,
  };

  @override
  IngredientLine? decode(String id, Map<String, Object?> fields) {
    if (fields case {
      'recipeId': final String recipeId,
      'rawText': final String rawText,
      'sortKey': final String sortKey,
    }) {
      final sectionId = fields['sectionId'] as String?;
      return IngredientLine(
        id: IngredientLineId(id),
        recipeId: RecipeId(recipeId),
        rawText: rawText,
        sortKey: SortKey(sortKey),
        sectionId: sectionId == null ? null : IngredientSectionId(sectionId),
        quantity: decodeQuantity(fields['quantity']),
        quantityMax: decodeQuantity(fields['quantityMax']),
        unit: decodeEnum(Unit.values, fields['unit']),
        countWord: fields['countWord'] as String?,
        name: fields['name'] as String?,
        preparation: fields['preparation'] as String?,
      );
    }
    return null;
  }
}

/// [StepSection] fields in the change log.
final class StepSectionCodec() implements EntityCodec<StepSection> {
  @override
  String get entity => 'step_section';

  @override
  String idOf(StepSection value) => value.id.value;

  @override
  Map<String, Object?> encode(StepSection value) => {
    'recipeId': value.recipeId.value,
    'name': value.name,
    'sortKey': value.sortKey.value,
  };

  @override
  StepSection? decode(String id, Map<String, Object?> fields) =>
      switch (fields) {
        {
          'recipeId': final String recipeId,
          'name': final String name,
          'sortKey': final String sortKey,
        } =>
          StepSection(
            id: StepSectionId(id),
            recipeId: RecipeId(recipeId),
            name: name,
            sortKey: SortKey(sortKey),
          ),
        _ => null,
      };
}

/// [RecipeStep] fields in the change log.
final class RecipeStepCodec() implements EntityCodec<RecipeStep> {
  @override
  String get entity => 'recipe_step';

  @override
  String idOf(RecipeStep value) => value.id.value;

  @override
  Map<String, Object?> encode(RecipeStep value) => {
    'recipeId': value.recipeId.value,
    'text': value.text,
    'sortKey': value.sortKey.value,
    'sectionId': value.sectionId?.value,
  };

  @override
  RecipeStep? decode(String id, Map<String, Object?> fields) {
    if (fields case {
      'recipeId': final String recipeId,
      'text': final String text,
      'sortKey': final String sortKey,
    }) {
      final sectionId = fields['sectionId'] as String?;
      return RecipeStep(
        id: RecipeStepId(id),
        recipeId: RecipeId(recipeId),
        text: text,
        sortKey: SortKey(sortKey),
        sectionId: sectionId == null ? null : StepSectionId(sectionId),
      );
    }
    return null;
  }
}
