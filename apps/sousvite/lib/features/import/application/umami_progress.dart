import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'umami_progress.g.dart';

/// The steps of an Umami import, in order.
enum UmamiImportStage() {
  /// Reading the recipes out of the export file.
  reading,

  /// Saving each recipe.
  recipes,

  /// Downloading and saving each recipe's photo.
  photos,
}

/// How far an Umami import has got: [done] of [total] in [stage].
@immutable
class const UmamiImportProgress(
  /// The step the import is on.
  final UmamiImportStage stage, {

  /// How many items of the step are finished.
  final int done = 0,

  /// How many items the step has. Zero while it isn't known yet.
  final int total = 0,
}) {
  /// How much of the step is finished, from 0 to 1, or null while the
  /// total isn't known.
  double? get fraction => total == 0 ? null : done / total;

  @override
  bool operator ==(Object other) =>
      other is UmamiImportProgress &&
      other.stage == stage &&
      other.done == done &&
      other.total == total;

  @override
  int get hashCode => Object.hash(stage, done, total);
}

/// The running Umami import's progress, or null when none is running.
/// `UmamiActions` reports into it.
@riverpod
class UmamiProgress() extends _$UmamiProgress {
  @override
  UmamiImportProgress? build() => null;

  /// Shows [progress], or null once the import ends.
  void report(UmamiImportProgress? progress) {
    if (progress != state) state = progress;
  }
}
