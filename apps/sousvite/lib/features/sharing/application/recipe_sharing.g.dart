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

String _$recipeSharingHash() => r'066368629d1c627fa4d893ea962b6a58075d05ef';
