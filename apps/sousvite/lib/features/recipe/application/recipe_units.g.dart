// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_units.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// This user's settings for one recipe, or null until they change one.

@ProviderFor(recipePrefs)
final recipePrefsProvider = RecipePrefsFamily._();

/// This user's settings for one recipe, or null until they change one.

final class RecipePrefsProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserRecipePrefs?>,
          UserRecipePrefs?,
          Stream<UserRecipePrefs?>
        >
    with $FutureModifier<UserRecipePrefs?>, $StreamProvider<UserRecipePrefs?> {
  /// This user's settings for one recipe, or null until they change one.
  RecipePrefsProvider._({
    required RecipePrefsFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'recipePrefsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recipePrefsHash();

  @override
  String toString() {
    return r'recipePrefsProvider'
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
    return recipePrefs(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecipePrefsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recipePrefsHash() => r'2624cc811971763c7b4645d58a4b3206090671a7';

/// This user's settings for one recipe, or null until they change one.

final class RecipePrefsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<UserRecipePrefs?>, RecipeId> {
  RecipePrefsFamily._()
    : super(
        retry: null,
        name: r'recipePrefsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// This user's settings for one recipe, or null until they change one.

  RecipePrefsProvider call(RecipeId recipeId) =>
      RecipePrefsProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'recipePrefsProvider';
}

/// Which units this recipe's amounts are shown in: as written, US, or
/// metric (PRD 7.6). Remembered per recipe in `UserRecipePrefs`, so each
/// member of a joint share keeps their own choice.

@ProviderFor(RecipeUnitSystem)
final recipeUnitSystemProvider = RecipeUnitSystemFamily._();

/// Which units this recipe's amounts are shown in: as written, US, or
/// metric (PRD 7.6). Remembered per recipe in `UserRecipePrefs`, so each
/// member of a joint share keeps their own choice.
final class RecipeUnitSystemProvider
    extends $NotifierProvider<RecipeUnitSystem, UnitSystem> {
  /// Which units this recipe's amounts are shown in: as written, US, or
  /// metric (PRD 7.6). Remembered per recipe in `UserRecipePrefs`, so each
  /// member of a joint share keeps their own choice.
  RecipeUnitSystemProvider._({
    required RecipeUnitSystemFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'recipeUnitSystemProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recipeUnitSystemHash();

  @override
  String toString() {
    return r'recipeUnitSystemProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RecipeUnitSystem create() => RecipeUnitSystem();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnitSystem value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnitSystem>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RecipeUnitSystemProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recipeUnitSystemHash() => r'c8c9a57b3eaa577ea0e9a0872ea9cf0533751778';

/// Which units this recipe's amounts are shown in: as written, US, or
/// metric (PRD 7.6). Remembered per recipe in `UserRecipePrefs`, so each
/// member of a joint share keeps their own choice.

final class RecipeUnitSystemFamily extends $Family
    with
        $ClassFamilyOverride<
          RecipeUnitSystem,
          UnitSystem,
          UnitSystem,
          UnitSystem,
          RecipeId
        > {
  RecipeUnitSystemFamily._()
    : super(
        retry: null,
        name: r'recipeUnitSystemProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Which units this recipe's amounts are shown in: as written, US, or
  /// metric (PRD 7.6). Remembered per recipe in `UserRecipePrefs`, so each
  /// member of a joint share keeps their own choice.

  RecipeUnitSystemProvider call(RecipeId recipeId) =>
      RecipeUnitSystemProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'recipeUnitSystemProvider';
}

/// Which units this recipe's amounts are shown in: as written, US, or
/// metric (PRD 7.6). Remembered per recipe in `UserRecipePrefs`, so each
/// member of a joint share keeps their own choice.

abstract class _$RecipeUnitSystem extends $Notifier<UnitSystem> {
  late final _$args = ref.$arg as RecipeId;
  RecipeId get recipeId => _$args;

  UnitSystem build(RecipeId recipeId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UnitSystem, UnitSystem>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UnitSystem, UnitSystem>,
              UnitSystem,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
