// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_line_parser.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The parser the editor uses: `package:ingredient_parser`. A provider, so
/// tests can swap it.

@ProviderFor(ingredientLineParser)
final ingredientLineParserProvider = IngredientLineParserProvider._();

/// The parser the editor uses: `package:ingredient_parser`. A provider, so
/// tests can swap it.

final class IngredientLineParserProvider
    extends
        $FunctionalProvider<
          IngredientLineParser,
          IngredientLineParser,
          IngredientLineParser
        >
    with $Provider<IngredientLineParser> {
  /// The parser the editor uses: `package:ingredient_parser`. A provider, so
  /// tests can swap it.
  IngredientLineParserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ingredientLineParserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ingredientLineParserHash();

  @$internal
  @override
  $ProviderElement<IngredientLineParser> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IngredientLineParser create(Ref ref) {
    return ingredientLineParser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IngredientLineParser value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IngredientLineParser>(value),
    );
  }
}

String _$ingredientLineParserHash() =>
    r'ba72444c67fdd843ab45808b87b45a5e5e778bf2';
