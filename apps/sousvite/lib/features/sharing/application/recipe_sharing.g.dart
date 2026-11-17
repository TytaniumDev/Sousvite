// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_sharing.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recipeSharing)
final recipeSharingProvider = RecipeSharingProvider._();

final class RecipeSharingProvider
    extends $FunctionalProvider<RecipeSharing, RecipeSharing, RecipeSharing>
    with $Provider<RecipeSharing> {
  RecipeSharingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recipeSharingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recipeSharingHash();

  @$internal
  @override
  $ProviderElement<RecipeSharing> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RecipeSharing create(Ref ref) {
    return recipeSharing(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecipeSharing value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecipeSharing>(value),
    );
  }
}

String _$recipeSharingHash() => r'511ee3d56b129830ea70fd97e8cea3992c4162a3';

/// The joint share [recipeId] is in, or null when it's only the user's.

@ProviderFor(recipeSharedSpace)
final recipeSharedSpaceProvider = RecipeSharedSpaceFamily._();

/// The joint share [recipeId] is in, or null when it's only the user's.

final class RecipeSharedSpaceProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  /// The joint share [recipeId] is in, or null when it's only the user's.
  RecipeSharedSpaceProvider._({
    required RecipeSharedSpaceFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'recipeSharedSpaceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recipeSharedSpaceHash();

  @override
  String toString() {
    return r'recipeSharedSpaceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    final argument = this.argument as RecipeId;
    return recipeSharedSpace(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecipeSharedSpaceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recipeSharedSpaceHash() => r'e7a45cc4ee357a2a7139f8700ef2cac484508ff8';

/// The joint share [recipeId] is in, or null when it's only the user's.

final class RecipeSharedSpaceFamily extends $Family
    with $FunctionalFamilyOverride<Stream<String?>, RecipeId> {
  RecipeSharedSpaceFamily._()
    : super(
        retry: null,
        name: r'recipeSharedSpaceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The joint share [recipeId] is in, or null when it's only the user's.

  RecipeSharedSpaceProvider call(RecipeId recipeId) =>
      RecipeSharedSpaceProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'recipeSharedSpaceProvider';
}
