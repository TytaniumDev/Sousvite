import 'dart:async';

import 'package:domain/domain.dart';
import 'package:sousvite/features/import/application/recipe_importers.dart';

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

  @override
  Future<int?> importLibrary() => _run();

  @override
  Future<int?> exportLibrary() => _run();

  Future<int?> _run() async {
    await gate?.future;
    final count = await outcome();
    return count;
  }
}
