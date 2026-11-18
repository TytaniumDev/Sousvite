import 'dart:async';

import 'package:domain/domain.dart';
import 'package:sousvite/features/import/application/recipe_importers.dart';
import 'package:sousvite/features/import/application/umami_progress.dart';

/// A [UrlImporter] that answers with [result], or throws [failure].
class FakeUrlImporter() implements UrlImporter {
  final requested = <Uri>[];
  RecipeSnapshot? result;
  Exception? failure;

  /// Completes [importUrl] only when the test says so, to see progress.
  Completer<void>? gate;

  @override
  Future<RecipeSnapshot> importUrl(Uri url) async {
    requested.add(url);
    await gate?.future;
    if (failure case final failure?) throw failure;
    return result!;
  }
}

/// An [UmamiTransfer] whose outcome each test sets.
class FakeUmamiTransfer() implements UmamiTransfer {
  /// What both calls return or throw.
  FutureOr<int?> Function() outcome = () => null;

  /// Completes the calls only when the test says so.
  Completer<void>? gate;

  /// What the imports report before they wait on [gate].
  List<UmamiImportProgress> progress = const [];

  @override
  Future<int?> importLibrary({required UmamiProgressReport onProgress}) {
    progress.forEach(onProgress);
    return _run();
  }

  @override
  Future<int?> exportLibrary() => _run();

  /// The paths [importSharedArchive] was asked for.
  final sharedArchives = <String>[];

  @override
  Future<int> importSharedArchive(
    String path, {
    required UmamiProgressReport onProgress,
  }) async {
    sharedArchives.add(path);
    progress.forEach(onProgress);
    final count = await _run();
    return count ?? 0;
  }

  Future<int?> _run() async {
    await gate?.future;
    final count = await outcome();
    return count;
  }
}
