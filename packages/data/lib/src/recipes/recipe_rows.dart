import 'package:data/src/app_database.dart';
import 'package:domain/domain.dart';
import 'package:drift/drift.dart';

// Conversions between the recipe tables' rows and the domain entities.

Quantity? _quantity(int? numerator, int? denominator) =>
    numerator == null || denominator == null
    ? null
    : Quantity(numerator, denominator);

Duration? _seconds(int? seconds) =>
    seconds == null ? null : Duration(seconds: seconds);

/// Reads a [Recipe] from its row.
extension RecipeRowMapping on RecipeRow {
  /// The entity this row stores.
  Recipe toEntity() => Recipe(
    id: RecipeId(id),
    title: title,
    servings: Quantity(servingsNumerator, servingsDenominator),
    createdAt: createdAt,
    updatedAt: updatedAt,
    photoRef: photoRef,
    prepTime: _seconds(prepTimeSeconds),
    cookTime: _seconds(cookTimeSeconds),
    totalTime: _seconds(totalTimeSeconds),
    notes: notes,
    sourceUrl: sourceUrl,
    sourceName: sourceName,
  );
}

/// Writes a [Recipe] as a row.
extension RecipeCompanionMapping on Recipe {
  /// A row with every column set. Times are stored in UTC, so the text
  /// columns sort in time order.
  RecipesCompanion toCompanion() => RecipesCompanion.insert(
    id: id.value,
    title: title,
    servingsNumerator: servings.numerator,
    servingsDenominator: servings.denominator,
    createdAt: createdAt.toUtc(),
    updatedAt: updatedAt.toUtc(),
    photoRef: Value(photoRef),
    prepTimeSeconds: Value(prepTime?.inSeconds),
    cookTimeSeconds: Value(cookTime?.inSeconds),
    totalTimeSeconds: Value(totalTime?.inSeconds),
    notes: Value(notes),
    sourceUrl: Value(sourceUrl),
    sourceName: Value(sourceName),
  );
}

/// Reads an [IngredientSection] from its row.
extension IngredientSectionRowMapping on IngredientSectionRow {
  /// The entity this row stores.
  IngredientSection toEntity() => IngredientSection(
    id: IngredientSectionId(id),
    recipeId: RecipeId(recipeId),
    name: name,
    sortKey: SortKey(sortKey),
  );
}

/// Writes an [IngredientSection] as a row.
extension IngredientSectionCompanionMapping on IngredientSection {
  /// A row with every column set.
  IngredientSectionsCompanion toCompanion() =>
      IngredientSectionsCompanion.insert(
        id: id.value,
        recipeId: recipeId.value,
        name: name,
        sortKey: sortKey.value,
      );
}

/// Reads an [IngredientLine] from its row.
extension IngredientLineRowMapping on IngredientLineRow {
  /// The entity this row stores.
  IngredientLine toEntity() => IngredientLine(
    id: IngredientLineId(id),
    recipeId: RecipeId(recipeId),
    rawText: rawText,
    sortKey: SortKey(sortKey),
    sectionId: sectionId == null ? null : IngredientSectionId(sectionId!),
    quantity: _quantity(quantityNumerator, quantityDenominator),
    quantityMax: _quantity(quantityMaxNumerator, quantityMaxDenominator),
    unit: unit,
    countWord: countWord,
    name: name,
    preparation: preparation,
  );
}

/// Writes an [IngredientLine] as a row.
extension IngredientLineCompanionMapping on IngredientLine {
  /// A row with every column set.
  IngredientLinesCompanion toCompanion() => IngredientLinesCompanion.insert(
    id: id.value,
    recipeId: recipeId.value,
    rawText: rawText,
    sortKey: sortKey.value,
    sectionId: Value(sectionId?.value),
    quantityNumerator: Value(quantity?.numerator),
    quantityDenominator: Value(quantity?.denominator),
    quantityMaxNumerator: Value(quantityMax?.numerator),
    quantityMaxDenominator: Value(quantityMax?.denominator),
    unit: Value(unit),
    countWord: Value(countWord),
    name: Value(name),
    preparation: Value(preparation),
  );
}

/// Reads a [StepSection] from its row.
extension StepSectionRowMapping on StepSectionRow {
  /// The entity this row stores.
  StepSection toEntity() => StepSection(
    id: StepSectionId(id),
    recipeId: RecipeId(recipeId),
    name: name,
    sortKey: SortKey(sortKey),
  );
}

/// Writes a [StepSection] as a row.
extension StepSectionCompanionMapping on StepSection {
  /// A row with every column set.
  StepSectionsCompanion toCompanion() => StepSectionsCompanion.insert(
    id: id.value,
    recipeId: recipeId.value,
    name: name,
    sortKey: sortKey.value,
  );
}

/// Reads a [RecipeStep] from its row.
extension RecipeStepRowMapping on RecipeStepRow {
  /// The entity this row stores.
  RecipeStep toEntity() => RecipeStep(
    id: RecipeStepId(id),
    recipeId: RecipeId(recipeId),
    text: body,
    sortKey: SortKey(sortKey),
    sectionId: sectionId == null ? null : StepSectionId(sectionId!),
  );
}

/// Writes a [RecipeStep] as a row.
extension RecipeStepCompanionMapping on RecipeStep {
  /// A row with every column set.
  RecipeStepsCompanion toCompanion() => RecipeStepsCompanion.insert(
    id: id.value,
    recipeId: recipeId.value,
    body: text,
    sortKey: sortKey.value,
    sectionId: Value(sectionId?.value),
  );
}
