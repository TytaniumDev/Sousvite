import 'package:domain/domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_ref.freezed.dart';

/// One entry in a recipe's history timeline (PRD 7.11): a past version or
/// an experiment. Carries only what orders the timeline; each tile watches
/// its own entry by id.
@freezed
sealed class HistoryRef with _$HistoryRef {
  const factory version({
    required RecipeVersionId id,
    required DateTime createdAt,
  }) = VersionRef;

  const factory experiment({
    required ExperimentId id,
    required DateTime createdAt,
  }) = ExperimentRef;
}

/// A recipe's timeline, newest first. Compares by value, so editing an
/// experiment's notes doesn't rebuild the list, only that entry's tile.
@freezed
abstract class HistoryTimeline with _$HistoryTimeline {
  const factory({required List<HistoryRef> entries}) = _HistoryTimeline;
}
