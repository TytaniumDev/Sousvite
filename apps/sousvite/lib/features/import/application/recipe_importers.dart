import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/features/import/application/import_failure.dart';

part 'recipe_importers.g.dart';

/// Reads a recipe from a web page (ENGINEERING.md §14).
abstract interface class UrlImporter() {
  /// The recipe at [url], with new ids, not yet saved. Throws
  /// [ImportFailure] when it can't.
  Future<RecipeSnapshot> importUrl(Uri url);
}

/// Moves recipes in and out of Umami's export format (PRD 7.2).
abstract interface class UmamiTransfer() {
  /// Asks the user for an Umami export and saves its recipes. Returns how
  /// many were imported, or null if the user canceled. Throws
  /// [ImportFailure] when the file can't be read.
  Future<int?> importLibrary();

  /// Writes every recipe in Umami's format and hands the file to the
  /// user. Returns how many were exported, or null if the user canceled.
  Future<int?> exportLibrary();
}

/// Stands in until URL import (IMP-1) exists.
class const UnavailableUrlImporter() implements UrlImporter {
  @override
  Future<RecipeSnapshot> importUrl(Uri url) async =>
      throw ImportFailure(.notAvailable, site: url.host);
}

/// Stands in until Umami import and export (IMP-2) exist.
class const UnavailableUmamiTransfer() implements UmamiTransfer {
  @override
  Future<int?> importLibrary() async =>
      throw const ImportFailure(.notAvailable);

  @override
  Future<int?> exportLibrary() async =>
      throw const ImportFailure(.notAvailable);
}

@Riverpod(keepAlive: true)
UrlImporter urlImporter(Ref ref) => const UnavailableUrlImporter();

@Riverpod(keepAlive: true)
UmamiTransfer umamiTransfer(Ref ref) => const UnavailableUmamiTransfer();
