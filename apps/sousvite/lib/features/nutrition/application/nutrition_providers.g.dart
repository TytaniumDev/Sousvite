// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A recipe's ingredient lines, in order.

@ProviderFor(nutritionLines)
final nutritionLinesProvider = NutritionLinesFamily._();

/// A recipe's ingredient lines, in order.

final class NutritionLinesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<IngredientLine>>,
          List<IngredientLine>,
          Stream<List<IngredientLine>>
        >
    with
        $FutureModifier<List<IngredientLine>>,
        $StreamProvider<List<IngredientLine>> {
  /// A recipe's ingredient lines, in order.
  NutritionLinesProvider._({
    required NutritionLinesFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'nutritionLinesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nutritionLinesHash();

  @override
  String toString() {
    return r'nutritionLinesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<IngredientLine>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<IngredientLine>> create(Ref ref) {
    final argument = this.argument as RecipeId;
    return nutritionLines(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NutritionLinesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nutritionLinesHash() => r'459b2d8077a51ec64d43b59e49befc8455d6dc44';

/// A recipe's ingredient lines, in order.

final class NutritionLinesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<IngredientLine>>, RecipeId> {
  NutritionLinesFamily._()
    : super(
        retry: null,
        name: r'nutritionLinesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A recipe's ingredient lines, in order.

  NutritionLinesProvider call(RecipeId recipeId) =>
      NutritionLinesProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'nutritionLinesProvider';
}

/// The recipe's ingredient line ids, in order. Emits only when lines are
/// added, removed, or moved, so the match list doesn't rebuild on edits.

@ProviderFor(nutritionLineIds)
final nutritionLineIdsProvider = NutritionLineIdsFamily._();

/// The recipe's ingredient line ids, in order. Emits only when lines are
/// added, removed, or moved, so the match list doesn't rebuild on edits.

final class NutritionLineIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<IngredientLineId>>,
          List<IngredientLineId>,
          Stream<List<IngredientLineId>>
        >
    with
        $FutureModifier<List<IngredientLineId>>,
        $StreamProvider<List<IngredientLineId>> {
  /// The recipe's ingredient line ids, in order. Emits only when lines are
  /// added, removed, or moved, so the match list doesn't rebuild on edits.
  NutritionLineIdsProvider._({
    required NutritionLineIdsFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'nutritionLineIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nutritionLineIdsHash();

  @override
  String toString() {
    return r'nutritionLineIdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<IngredientLineId>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<IngredientLineId>> create(Ref ref) {
    final argument = this.argument as RecipeId;
    return nutritionLineIds(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NutritionLineIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nutritionLineIdsHash() => r'9e163d4687f074a996cde888f8af027a17248cc0';

/// The recipe's ingredient line ids, in order. Emits only when lines are
/// added, removed, or moved, so the match list doesn't rebuild on edits.

final class NutritionLineIdsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<IngredientLineId>>, RecipeId> {
  NutritionLineIdsFamily._()
    : super(
        retry: null,
        name: r'nutritionLineIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The recipe's ingredient line ids, in order. Emits only when lines are
  /// added, removed, or moved, so the match list doesn't rebuild on edits.

  NutritionLineIdsProvider call(RecipeId recipeId) =>
      NutritionLineIdsProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'nutritionLineIdsProvider';
}

/// Each matched line's match, by line id.

@ProviderFor(nutritionMatches)
final nutritionMatchesProvider = NutritionMatchesFamily._();

/// Each matched line's match, by line id.

final class NutritionMatchesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<IngredientLineId, NutritionMatch>>,
          Map<IngredientLineId, NutritionMatch>,
          Stream<Map<IngredientLineId, NutritionMatch>>
        >
    with
        $FutureModifier<Map<IngredientLineId, NutritionMatch>>,
        $StreamProvider<Map<IngredientLineId, NutritionMatch>> {
  /// Each matched line's match, by line id.
  NutritionMatchesProvider._({
    required NutritionMatchesFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'nutritionMatchesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nutritionMatchesHash();

  @override
  String toString() {
    return r'nutritionMatchesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<IngredientLineId, NutritionMatch>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<IngredientLineId, NutritionMatch>> create(Ref ref) {
    final argument = this.argument as RecipeId;
    return nutritionMatches(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NutritionMatchesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nutritionMatchesHash() => r'5821a58d96fcc7de4d71efb7e317cfd3c77522a8';

/// Each matched line's match, by line id.

final class NutritionMatchesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<Map<IngredientLineId, NutritionMatch>>,
          RecipeId
        > {
  NutritionMatchesFamily._()
    : super(
        retry: null,
        name: r'nutritionMatchesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Each matched line's match, by line id.

  NutritionMatchesProvider call(RecipeId recipeId) =>
      NutritionMatchesProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'nutritionMatchesProvider';
}

/// A food's name and source.

@ProviderFor(nutritionFood)
final nutritionFoodProvider = NutritionFoodFamily._();

/// A food's name and source.

final class NutritionFoodProvider
    extends $FunctionalProvider<AsyncValue<Food?>, Food?, FutureOr<Food?>>
    with $FutureModifier<Food?>, $FutureProvider<Food?> {
  /// A food's name and source.
  NutritionFoodProvider._({
    required NutritionFoodFamily super.from,
    required FoodId super.argument,
  }) : super(
         retry: null,
         name: r'nutritionFoodProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nutritionFoodHash();

  @override
  String toString() {
    return r'nutritionFoodProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Food?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Food?> create(Ref ref) {
    final argument = this.argument as FoodId;
    return nutritionFood(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NutritionFoodProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nutritionFoodHash() => r'85b32351a9f7d4b9cec75125cf15f3859f24819e';

/// A food's name and source.

final class NutritionFoodFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Food?>, FoodId> {
  NutritionFoodFamily._()
    : super(
        retry: null,
        name: r'nutritionFoodProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A food's name and source.

  NutritionFoodProvider call(FoodId foodId) =>
      NutritionFoodProvider._(argument: foodId, from: this);

  @override
  String toString() => r'nutritionFoodProvider';
}

/// A food's nutrients per 100 g.

@ProviderFor(foodNutrients)
final foodNutrientsProvider = FoodNutrientsFamily._();

/// A food's nutrients per 100 g.

final class FoodNutrientsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FoodNutrient>>,
          List<FoodNutrient>,
          FutureOr<List<FoodNutrient>>
        >
    with
        $FutureModifier<List<FoodNutrient>>,
        $FutureProvider<List<FoodNutrient>> {
  /// A food's nutrients per 100 g.
  FoodNutrientsProvider._({
    required FoodNutrientsFamily super.from,
    required FoodId super.argument,
  }) : super(
         retry: null,
         name: r'foodNutrientsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$foodNutrientsHash();

  @override
  String toString() {
    return r'foodNutrientsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<FoodNutrient>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FoodNutrient>> create(Ref ref) {
    final argument = this.argument as FoodId;
    return foodNutrients(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FoodNutrientsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$foodNutrientsHash() => r'fd59f7fe42d3629c847b4d77d2d75b37736e3064';

/// A food's nutrients per 100 g.

final class FoodNutrientsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<FoodNutrient>>, FoodId> {
  FoodNutrientsFamily._()
    : super(
        retry: null,
        name: r'foodNutrientsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A food's nutrients per 100 g.

  FoodNutrientsProvider call(FoodId foodId) =>
      FoodNutrientsProvider._(argument: foodId, from: this);

  @override
  String toString() => r'foodNutrientsProvider';
}

/// A food's household portions, for working out a line's weight.

@ProviderFor(foodPortions)
final foodPortionsProvider = FoodPortionsFamily._();

/// A food's household portions, for working out a line's weight.

final class FoodPortionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FoodPortion>>,
          List<FoodPortion>,
          FutureOr<List<FoodPortion>>
        >
    with
        $FutureModifier<List<FoodPortion>>,
        $FutureProvider<List<FoodPortion>> {
  /// A food's household portions, for working out a line's weight.
  FoodPortionsProvider._({
    required FoodPortionsFamily super.from,
    required FoodId super.argument,
  }) : super(
         retry: null,
         name: r'foodPortionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$foodPortionsHash();

  @override
  String toString() {
    return r'foodPortionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<FoodPortion>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FoodPortion>> create(Ref ref) {
    final argument = this.argument as FoodId;
    return foodPortions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FoodPortionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$foodPortionsHash() => r'8de3e6b6654f2d0e0182e774fffd50853b9af20d';

/// A food's household portions, for working out a line's weight.

final class FoodPortionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<FoodPortion>>, FoodId> {
  FoodPortionsFamily._()
    : super(
        retry: null,
        name: r'foodPortionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A food's household portions, for working out a line's weight.

  FoodPortionsProvider call(FoodId foodId) =>
      FoodPortionsProvider._(argument: foodId, from: this);

  @override
  String toString() => r'foodPortionsProvider';
}

/// This user's settings for a recipe, or null if never changed.

@ProviderFor(nutritionPrefs)
final nutritionPrefsProvider = NutritionPrefsFamily._();

/// This user's settings for a recipe, or null if never changed.

final class NutritionPrefsProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserRecipePrefs?>,
          UserRecipePrefs?,
          Stream<UserRecipePrefs?>
        >
    with $FutureModifier<UserRecipePrefs?>, $StreamProvider<UserRecipePrefs?> {
  /// This user's settings for a recipe, or null if never changed.
  NutritionPrefsProvider._({
    required NutritionPrefsFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'nutritionPrefsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nutritionPrefsHash();

  @override
  String toString() {
    return r'nutritionPrefsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<UserRecipePrefs?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<UserRecipePrefs?> create(Ref ref) {
    final argument = this.argument as RecipeId;
    return nutritionPrefs(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NutritionPrefsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nutritionPrefsHash() => r'83fb7ae4d50e326968b2e1c13fc7f659f1febe0d';

/// This user's settings for a recipe, or null if never changed.

final class NutritionPrefsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<UserRecipePrefs?>, RecipeId> {
  NutritionPrefsFamily._()
    : super(
        retry: null,
        name: r'nutritionPrefsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// This user's settings for a recipe, or null if never changed.

  NutritionPrefsProvider call(RecipeId recipeId) =>
      NutritionPrefsProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'nutritionPrefsProvider';
}

/// How many servings the recipe makes as written.

@ProviderFor(recipeYield)
final recipeYieldProvider = RecipeYieldFamily._();

/// How many servings the recipe makes as written.

final class RecipeYieldProvider
    extends
        $FunctionalProvider<AsyncValue<Quantity?>, Quantity?, Stream<Quantity?>>
    with $FutureModifier<Quantity?>, $StreamProvider<Quantity?> {
  /// How many servings the recipe makes as written.
  RecipeYieldProvider._({
    required RecipeYieldFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'recipeYieldProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recipeYieldHash();

  @override
  String toString() {
    return r'recipeYieldProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Quantity?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Quantity?> create(Ref ref) {
    final argument = this.argument as RecipeId;
    return recipeYield(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecipeYieldProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recipeYieldHash() => r'8159f055fc3baf941eb6bee6d3150a804ec54556';

/// How many servings the recipe makes as written.

final class RecipeYieldFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Quantity?>, RecipeId> {
  RecipeYieldFamily._()
    : super(
        retry: null,
        name: r'recipeYieldProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// How many servings the recipe makes as written.

  RecipeYieldProvider call(RecipeId recipeId) =>
      RecipeYieldProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'recipeYieldProvider';
}

/// The number of servings per-serving nutrition divides the batch into:
/// the user's remembered choice, else the recipe's own servings (PRD 7.4).

@ProviderFor(nutritionServings)
final nutritionServingsProvider = NutritionServingsFamily._();

/// The number of servings per-serving nutrition divides the batch into:
/// the user's remembered choice, else the recipe's own servings (PRD 7.4).

final class NutritionServingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Quantity>,
          AsyncValue<Quantity>,
          AsyncValue<Quantity>
        >
    with $Provider<AsyncValue<Quantity>> {
  /// The number of servings per-serving nutrition divides the batch into:
  /// the user's remembered choice, else the recipe's own servings (PRD 7.4).
  NutritionServingsProvider._({
    required NutritionServingsFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'nutritionServingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nutritionServingsHash();

  @override
  String toString() {
    return r'nutritionServingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<Quantity>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<Quantity> create(Ref ref) {
    final argument = this.argument as RecipeId;
    return nutritionServings(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<Quantity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<Quantity>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NutritionServingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nutritionServingsHash() => r'32d3faf118f6f338f1e55457e74384886c0ca543';

/// The number of servings per-serving nutrition divides the batch into:
/// the user's remembered choice, else the recipe's own servings (PRD 7.4).

final class NutritionServingsFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<Quantity>, RecipeId> {
  NutritionServingsFamily._()
    : super(
        retry: null,
        name: r'nutritionServingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The number of servings per-serving nutrition divides the batch into:
  /// the user's remembered choice, else the recipe's own servings (PRD 7.4).

  NutritionServingsProvider call(RecipeId recipeId) =>
      NutritionServingsProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'nutritionServingsProvider';
}

/// Nutrition for the whole batch, from every matched line.
///
/// Built synchronously from the matches and each food's nutrients, so a
/// change shows at once instead of passing through a loading state.

@ProviderFor(batchNutrition)
final batchNutritionProvider = BatchNutritionFamily._();

/// Nutrition for the whole batch, from every matched line.
///
/// Built synchronously from the matches and each food's nutrients, so a
/// change shows at once instead of passing through a loading state.

final class BatchNutritionProvider
    extends
        $FunctionalProvider<
          AsyncValue<NutrientAmounts>,
          AsyncValue<NutrientAmounts>,
          AsyncValue<NutrientAmounts>
        >
    with $Provider<AsyncValue<NutrientAmounts>> {
  /// Nutrition for the whole batch, from every matched line.
  ///
  /// Built synchronously from the matches and each food's nutrients, so a
  /// change shows at once instead of passing through a loading state.
  BatchNutritionProvider._({
    required BatchNutritionFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'batchNutritionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$batchNutritionHash();

  @override
  String toString() {
    return r'batchNutritionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<NutrientAmounts>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<NutrientAmounts> create(Ref ref) {
    final argument = this.argument as RecipeId;
    return batchNutrition(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<NutrientAmounts> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<NutrientAmounts>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BatchNutritionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$batchNutritionHash() => r'2c765213badb87d0b96b6c361cb6764f59d2f682';

/// Nutrition for the whole batch, from every matched line.
///
/// Built synchronously from the matches and each food's nutrients, so a
/// change shows at once instead of passing through a loading state.

final class BatchNutritionFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<NutrientAmounts>, RecipeId> {
  BatchNutritionFamily._()
    : super(
        retry: null,
        name: r'batchNutritionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Nutrition for the whole batch, from every matched line.
  ///
  /// Built synchronously from the matches and each food's nutrients, so a
  /// change shows at once instead of passing through a loading state.

  BatchNutritionProvider call(RecipeId recipeId) =>
      BatchNutritionProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'batchNutritionProvider';
}

/// Nutrition on the basis the user picked: one serving or the batch.

@ProviderFor(displayedNutrition)
final displayedNutritionProvider = DisplayedNutritionFamily._();

/// Nutrition on the basis the user picked: one serving or the batch.

final class DisplayedNutritionProvider
    extends
        $FunctionalProvider<
          AsyncValue<NutrientAmounts>,
          AsyncValue<NutrientAmounts>,
          AsyncValue<NutrientAmounts>
        >
    with $Provider<AsyncValue<NutrientAmounts>> {
  /// Nutrition on the basis the user picked: one serving or the batch.
  DisplayedNutritionProvider._({
    required DisplayedNutritionFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'displayedNutritionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$displayedNutritionHash();

  @override
  String toString() {
    return r'displayedNutritionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<NutrientAmounts>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<NutrientAmounts> create(Ref ref) {
    final argument = this.argument as RecipeId;
    return displayedNutrition(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<NutrientAmounts> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<NutrientAmounts>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DisplayedNutritionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$displayedNutritionHash() =>
    r'030113df0109ca329868c79d70d0474603d8e664';

/// Nutrition on the basis the user picked: one serving or the batch.

final class DisplayedNutritionFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<NutrientAmounts>, RecipeId> {
  DisplayedNutritionFamily._()
    : super(
        retry: null,
        name: r'displayedNutritionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Nutrition on the basis the user picked: one serving or the batch.

  DisplayedNutritionProvider call(RecipeId recipeId) =>
      DisplayedNutritionProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'displayedNutritionProvider';
}

/// Lines with no match, in order. Their nutrition is missing from the
/// totals, so the screen flags them (PRD 7.4).

@ProviderFor(unmatchedLineIds)
final unmatchedLineIdsProvider = UnmatchedLineIdsFamily._();

/// Lines with no match, in order. Their nutrition is missing from the
/// totals, so the screen flags them (PRD 7.4).

final class UnmatchedLineIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<IngredientLineId>>,
          AsyncValue<List<IngredientLineId>>,
          AsyncValue<List<IngredientLineId>>
        >
    with $Provider<AsyncValue<List<IngredientLineId>>> {
  /// Lines with no match, in order. Their nutrition is missing from the
  /// totals, so the screen flags them (PRD 7.4).
  UnmatchedLineIdsProvider._({
    required UnmatchedLineIdsFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'unmatchedLineIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$unmatchedLineIdsHash();

  @override
  String toString() {
    return r'unmatchedLineIdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<List<IngredientLineId>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<IngredientLineId>> create(Ref ref) {
    final argument = this.argument as RecipeId;
    return unmatchedLineIds(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<IngredientLineId>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<IngredientLineId>>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UnmatchedLineIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$unmatchedLineIdsHash() => r'9a57266f0b6a15ee1a6ec9059ee835e97b505458';

/// Lines with no match, in order. Their nutrition is missing from the
/// totals, so the screen flags them (PRD 7.4).

final class UnmatchedLineIdsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          AsyncValue<List<IngredientLineId>>,
          RecipeId
        > {
  UnmatchedLineIdsFamily._()
    : super(
        retry: null,
        name: r'unmatchedLineIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Lines with no match, in order. Their nutrition is missing from the
  /// totals, so the screen flags them (PRD 7.4).

  UnmatchedLineIdsProvider call(RecipeId recipeId) =>
      UnmatchedLineIdsProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'unmatchedLineIdsProvider';
}

/// The packaged food with [barcode], from USDA branded foods or Open Food
/// Facts, or null when neither knows it. A failed lookup isn't retried on
/// its own: the scanner says so at once and offers "Try again".

@ProviderFor(barcodeFood)
final barcodeFoodProvider = BarcodeFoodFamily._();

/// The packaged food with [barcode], from USDA branded foods or Open Food
/// Facts, or null when neither knows it. A failed lookup isn't retried on
/// its own: the scanner says so at once and offers "Try again".

final class BarcodeFoodProvider
    extends
        $FunctionalProvider<
          AsyncValue<OnlineFood?>,
          OnlineFood?,
          FutureOr<OnlineFood?>
        >
    with $FutureModifier<OnlineFood?>, $FutureProvider<OnlineFood?> {
  /// The packaged food with [barcode], from USDA branded foods or Open Food
  /// Facts, or null when neither knows it. A failed lookup isn't retried on
  /// its own: the scanner says so at once and offers "Try again".
  BarcodeFoodProvider._({
    required BarcodeFoodFamily super.from,
    required String super.argument,
  }) : super(
         retry: _noRetry,
         name: r'barcodeFoodProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$barcodeFoodHash();

  @override
  String toString() {
    return r'barcodeFoodProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<OnlineFood?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OnlineFood?> create(Ref ref) {
    final argument = this.argument as String;
    return barcodeFood(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BarcodeFoodProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$barcodeFoodHash() => r'9d412e6b3d6ee35395f2a44bf8a2b939ed5cf11c';

/// The packaged food with [barcode], from USDA branded foods or Open Food
/// Facts, or null when neither knows it. A failed lookup isn't retried on
/// its own: the scanner says so at once and offers "Try again".

final class BarcodeFoodFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<OnlineFood?>, String> {
  BarcodeFoodFamily._()
    : super(
        retry: _noRetry,
        name: r'barcodeFoodProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The packaged food with [barcode], from USDA branded foods or Open Food
  /// Facts, or null when neither knows it. A failed lookup isn't retried on
  /// its own: the scanner says so at once and offers "Try again".

  BarcodeFoodProvider call(String barcode) =>
      BarcodeFoodProvider._(argument: barcode, from: this);

  @override
  String toString() => r'barcodeFoodProvider';
}

/// Foods matching [query] for changing a match: bundled and cached foods
/// first, since generic USDA data is the most accurate, then branded
/// products found online (PRD 7.4).

@ProviderFor(foodSearch)
final foodSearchProvider = FoodSearchFamily._();

/// Foods matching [query] for changing a match: bundled and cached foods
/// first, since generic USDA data is the most accurate, then branded
/// products found online (PRD 7.4).

final class FoodSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FoodChoice>>,
          List<FoodChoice>,
          FutureOr<List<FoodChoice>>
        >
    with $FutureModifier<List<FoodChoice>>, $FutureProvider<List<FoodChoice>> {
  /// Foods matching [query] for changing a match: bundled and cached foods
  /// first, since generic USDA data is the most accurate, then branded
  /// products found online (PRD 7.4).
  FoodSearchProvider._({
    required FoodSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'foodSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$foodSearchHash();

  @override
  String toString() {
    return r'foodSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<FoodChoice>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FoodChoice>> create(Ref ref) {
    final argument = this.argument as String;
    return foodSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FoodSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$foodSearchHash() => r'56bc8021e548ccfd0d8795830dba81c156d005e1';

/// Foods matching [query] for changing a match: bundled and cached foods
/// first, since generic USDA data is the most accurate, then branded
/// products found online (PRD 7.4).

final class FoodSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<FoodChoice>>, String> {
  FoodSearchFamily._()
    : super(
        retry: null,
        name: r'foodSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Foods matching [query] for changing a match: bundled and cached foods
  /// first, since generic USDA data is the most accurate, then branded
  /// products found online (PRD 7.4).

  FoodSearchProvider call(String query) =>
      FoodSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'foodSearchProvider';
}
