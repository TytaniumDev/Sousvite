import 'package:sousvite/features/import/application/import_failure.dart';
import 'package:sousvite/l10n/l10n.dart';

/// What went wrong and what to do next, in words.
extension ImportFailureText on AppLocalizations {
  /// The message for [failure].
  String importFailure(ImportFailure failure) {
    final site = failure.site ?? import_thisSite;
    return switch (failure.reason) {
      .invalidUrl => import_invalidUrl,
      .unreachable => import_unreachable(site),
      .noRecipe => import_noRecipe(site),
      .invalidFile => import_invalidFile,
      .notAvailable => import_notAvailable,
    };
  }
}
