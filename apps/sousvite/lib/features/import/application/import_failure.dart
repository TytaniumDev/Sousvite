/// Why an import failed, so the screen can say what to do next (PRD 7.2).
enum ImportFailureReason() {
  /// The text isn't a web address.
  invalidUrl,

  /// The site couldn't be reached or didn't answer.
  unreachable,

  /// The page loaded but has no recipe the importer can read.
  noRecipe,

  /// The file isn't an Umami export.
  invalidFile,

  /// This kind of import isn't built yet.
  notAvailable,
}

/// A failed import. Importers throw it; anything else they throw is a bug.
class const ImportFailure(
  /// Why it failed.
  final ImportFailureReason reason, {

  /// The site the recipe came from, when there is one: "seriouseats.com".
  final String? site,
}) implements Exception {
  @override
  String toString() => 'ImportFailure(${reason.name}, $site)';
}
