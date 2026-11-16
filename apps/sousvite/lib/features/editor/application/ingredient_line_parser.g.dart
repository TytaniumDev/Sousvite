// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_line_parser.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The parser the editor uses.
///
/// Until the ingredient parser (PAR-1) lands, the whole line is the name,
/// so nothing is lost. PAR-1 replaces this body with
/// `package:ingredient_parser`; nothing else changes.

@ProviderFor(ingredientLineParser)
final ingredientLineParserProvider = IngredientLineParserProvider._();

/// The parser the editor uses.
///
/// Until the ingredient parser (PAR-1) lands, the whole line is the name,
/// so nothing is lost. PAR-1 replaces this body with
/// `package:ingredient_parser`; nothing else changes.

final class IngredientLineParserProvider
    extends
        $FunctionalProvider<
          IngredientLineParser,
          IngredientLineParser,
          IngredientLineParser
        >
    with $Provider<IngredientLineParser> {
  /// The parser the editor uses.
  ///
  /// Until the ingredient parser (PAR-1) lands, the whole line is the name,
  /// so nothing is lost. PAR-1 replaces this body with
  /// `package:ingredient_parser`; nothing else changes.
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
    r'37dec9bda5821b100a92a2498e89b4d62921ae65';
