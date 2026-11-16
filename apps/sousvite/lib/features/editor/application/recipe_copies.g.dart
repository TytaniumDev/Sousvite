// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_copies.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Duplicates, deletes, and restores whole recipes from the editor.

@ProviderFor(recipeCopies)
final recipeCopiesProvider = RecipeCopiesProvider._();

/// Duplicates, deletes, and restores whole recipes from the editor.

final class RecipeCopiesProvider
    extends $FunctionalProvider<RecipeCopies, RecipeCopies, RecipeCopies>
    with $Provider<RecipeCopies> {
  /// Duplicates, deletes, and restores whole recipes from the editor.
  RecipeCopiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recipeCopiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recipeCopiesHash();

  @$internal
  @override
  $ProviderElement<RecipeCopies> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RecipeCopies create(Ref ref) {
    return recipeCopies(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecipeCopies value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecipeCopies>(value),
    );
  }
}

String _$recipeCopiesHash() => r'028e43f47ad658110d444257db01c74c3646712f';
