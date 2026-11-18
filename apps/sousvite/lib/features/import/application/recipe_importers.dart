import 'package:cloud_functions/cloud_functions.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/app/services/firebase.dart';
import 'package:sousvite/features/import/application/import_failure.dart';
import 'package:sousvite/features/import/application/umami_progress.dart';
import 'package:sousvite/features/import/data/library_umami_transfer.dart';
import 'package:sousvite/features/import/data/page_fetchers.dart';
import 'package:sousvite/features/import/data/page_url_importer.dart';
import 'package:sousvite/features/import/data/umami_files.dart';
import 'package:sousvite/features/nutrition/nutrition.dart';
import 'package:sousvite/shared/photos/photos.dart';
import 'package:uuid/uuid.dart';

part 'recipe_importers.g.dart';

/// Reads a recipe from a web page (ENGINEERING.md §14).
abstract interface class UrlImporter() {
  /// The recipe at [url], with new ids, not yet saved. Throws
  /// [ImportFailure] when it can't.
  Future<RecipeSnapshot> importUrl(Uri url);
}

/// Reports how far an Umami import has got.
typedef UmamiProgressReport = void Function(UmamiImportProgress progress);

/// Moves recipes in and out of Umami's export format (PRD 7.2).
abstract interface class UmamiTransfer() {
  /// Asks the user for an Umami export and saves its recipes, reporting
  /// each step to [onProgress] once a file is picked. Returns how many
  /// were imported, or null if the user canceled. Throws [ImportFailure]
  /// when the file can't be read.
  Future<int?> importLibrary({required UmamiProgressReport onProgress});

  /// Saves the recipes in the Umami export that another app shared into
  /// this one, which the platform left at [path], reporting each step to
  /// [onProgress]. Returns how many were imported. Throws [ImportFailure]
  /// when the file can't be read.
  Future<int> importSharedArchive(
    String path, {
    required UmamiProgressReport onProgress,
  });

  /// Writes every recipe in Umami's format and hands the file to the
  /// user. Returns how many were exported, or null if the user canceled.
  Future<int?> exportLibrary();
}

/// Stands in where URL import can't work: on web without Firebase, which
/// fetches pages through our proxy.
class const UnavailableUrlImporter() implements UrlImporter {
  @override
  Future<RecipeSnapshot> importUrl(Uri url) async =>
      throw ImportFailure(.notAvailable, site: url.host);
}

/// Fetches pages straight from the site on iOS and Android, and through
/// the fetch proxy on web.
@Riverpod(keepAlive: true)
UrlImporter urlImporter(Ref ref) {
  if (kIsWeb) {
    final app = ref.watch(firebaseAppProvider);
    if (app == null) return const UnavailableUrlImporter();
    return PageUrlImporter(
      proxyPageFetcher(
        FirebaseFunctions.instanceFor(app: app, region: 'us-central1'),
      ),
      newId: const Uuid().v4,
      importPhoto: ref.watch(recipePhotosProvider).importFrom,
    );
  }
  final client = http.Client();
  ref.onDispose(client.close);
  return PageUrlImporter(
    directPageFetcher(client),
    newId: const Uuid().v4,
    importPhoto: ref.watch(recipePhotosProvider).importFrom,
  );
}

/// The whole library, through the system file picker.
@Riverpod(keepAlive: true)
UmamiTransfer umamiTransfer(Ref ref) => LibraryUmamiTransfer(
  files: const SystemUmamiFiles(),
  recipes: ref.watch(recipeRepositoryProvider),
  folders: ref.watch(folderRepositoryProvider),
  newId: const Uuid().v4,
  importPhoto: ref.watch(recipePhotosProvider).importFrom,
  matchNutrition: (recipeId) async {
    final autoMatch = await ref.read(autoMatchProvider.future);
    await autoMatch.matchRecipe(recipeId);
  },
);
