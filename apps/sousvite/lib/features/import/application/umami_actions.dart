import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/features/import/application/recipe_importers.dart';
import 'package:sousvite/features/import/application/umami_progress.dart';

part 'umami_actions.g.dart';

/// Which Umami transfer is running, if any.
enum UmamiTask() {
  importing,
  exporting,
}

/// Runs one Umami import or export at a time. The state is the running
/// task, or null when idle.
@riverpod
class UmamiActions() extends _$UmamiActions {
  @override
  UmamiTask? build() => null;

  /// Imports an Umami library. Returns how many recipes came in, or null
  /// if the user canceled. Rethrows failures for the screen to report.
  Future<int?> importLibrary() => _run(
    .importing,
    () => ref.read(umamiTransferProvider).importLibrary(onProgress: _report),
  );

  /// Imports the Umami export another app shared into this one, at [path].
  /// Returns how many recipes came in, or null if a transfer was already
  /// running.
  Future<int?> importSharedArchive(String path) => _run(
    .importing,
    () => ref
        .read(umamiTransferProvider)
        .importSharedArchive(path, onProgress: _report),
  );

  /// Exports every recipe for Umami. Returns how many went out, or null if
  /// the user canceled.
  Future<int?> exportLibrary() =>
      _run(.exporting, ref.read(umamiTransferProvider).exportLibrary);

  void _report(UmamiImportProgress? progress) =>
      ref.read(umamiProgressProvider.notifier).report(progress);

  Future<int?> _run(UmamiTask task, Future<int?> Function() transfer) async {
    if (state != null) return null;
    state = task;
    try {
      return await transfer();
    } finally {
      if (ref.mounted) {
        state = null;
        _report(null);
      }
    }
  }
}
