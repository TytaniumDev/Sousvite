// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A recipe's past versions, newest first.

@ProviderFor(recipeVersions)
final recipeVersionsProvider = RecipeVersionsFamily._();

/// A recipe's past versions, newest first.

final class RecipeVersionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecipeVersion>>,
          List<RecipeVersion>,
          Stream<List<RecipeVersion>>
        >
    with
        $FutureModifier<List<RecipeVersion>>,
        $StreamProvider<List<RecipeVersion>> {
  /// A recipe's past versions, newest first.
  RecipeVersionsProvider._({
    required RecipeVersionsFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'recipeVersionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recipeVersionsHash();

  @override
  String toString() {
    return r'recipeVersionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<RecipeVersion>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RecipeVersion>> create(Ref ref) {
    final argument = this.argument as RecipeId;
    return recipeVersions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecipeVersionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recipeVersionsHash() => r'89fd02fe53ca5ea176aaa579451fde7ebad6db25';

/// A recipe's past versions, newest first.

final class RecipeVersionsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RecipeVersion>>, RecipeId> {
  RecipeVersionsFamily._()
    : super(
        retry: null,
        name: r'recipeVersionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A recipe's past versions, newest first.

  RecipeVersionsProvider call(RecipeId recipeId) =>
      RecipeVersionsProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'recipeVersionsProvider';
}

/// A recipe's experiments, newest first.

@ProviderFor(recipeExperiments)
final recipeExperimentsProvider = RecipeExperimentsFamily._();

/// A recipe's experiments, newest first.

final class RecipeExperimentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Experiment>>,
          List<Experiment>,
          Stream<List<Experiment>>
        >
    with $FutureModifier<List<Experiment>>, $StreamProvider<List<Experiment>> {
  /// A recipe's experiments, newest first.
  RecipeExperimentsProvider._({
    required RecipeExperimentsFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'recipeExperimentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recipeExperimentsHash();

  @override
  String toString() {
    return r'recipeExperimentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Experiment>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Experiment>> create(Ref ref) {
    final argument = this.argument as RecipeId;
    return recipeExperiments(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecipeExperimentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recipeExperimentsHash() => r'e37a3fb6446e88a3116cd91d9bda74c930af966e';

/// A recipe's experiments, newest first.

final class RecipeExperimentsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Experiment>>, RecipeId> {
  RecipeExperimentsFamily._()
    : super(
        retry: null,
        name: r'recipeExperimentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A recipe's experiments, newest first.

  RecipeExperimentsProvider call(RecipeId recipeId) =>
      RecipeExperimentsProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'recipeExperimentsProvider';
}

/// Versions and experiments together, newest first.

@ProviderFor(historyTimeline)
final historyTimelineProvider = HistoryTimelineFamily._();

/// Versions and experiments together, newest first.

final class HistoryTimelineProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HistoryRef>>,
          AsyncValue<List<HistoryRef>>,
          AsyncValue<List<HistoryRef>>
        >
    with $Provider<AsyncValue<List<HistoryRef>>> {
  /// Versions and experiments together, newest first.
  HistoryTimelineProvider._({
    required HistoryTimelineFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'historyTimelineProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$historyTimelineHash();

  @override
  String toString() {
    return r'historyTimelineProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<List<HistoryRef>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<HistoryRef>> create(Ref ref) {
    final argument = this.argument as RecipeId;
    return historyTimeline(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<HistoryRef>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<HistoryRef>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HistoryTimelineProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$historyTimelineHash() => r'ee67e29ae02597fa25115df14c003c5ec87662b4';

/// Versions and experiments together, newest first.

final class HistoryTimelineFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<List<HistoryRef>>, RecipeId> {
  HistoryTimelineFamily._()
    : super(
        retry: null,
        name: r'historyTimelineProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Versions and experiments together, newest first.

  HistoryTimelineProvider call(RecipeId recipeId) =>
      HistoryTimelineProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'historyTimelineProvider';
}

/// One experiment of [recipeId], or null once it is deleted.

@ProviderFor(historyExperiment)
final historyExperimentProvider = HistoryExperimentFamily._();

/// One experiment of [recipeId], or null once it is deleted.

final class HistoryExperimentProvider
    extends
        $FunctionalProvider<
          AsyncValue<Experiment?>,
          AsyncValue<Experiment?>,
          AsyncValue<Experiment?>
        >
    with $Provider<AsyncValue<Experiment?>> {
  /// One experiment of [recipeId], or null once it is deleted.
  HistoryExperimentProvider._({
    required HistoryExperimentFamily super.from,
    required (RecipeId, ExperimentId) super.argument,
  }) : super(
         retry: null,
         name: r'historyExperimentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$historyExperimentHash();

  @override
  String toString() {
    return r'historyExperimentProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<Experiment?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<Experiment?> create(Ref ref) {
    final argument = this.argument as (RecipeId, ExperimentId);
    return historyExperiment(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<Experiment?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<Experiment?>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HistoryExperimentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$historyExperimentHash() => r'0305fd78525af759fcfe393b36788c152b915c22';

/// One experiment of [recipeId], or null once it is deleted.

final class HistoryExperimentFamily extends $Family
    with
        $FunctionalFamilyOverride<
          AsyncValue<Experiment?>,
          (RecipeId, ExperimentId)
        > {
  HistoryExperimentFamily._()
    : super(
        retry: null,
        name: r'historyExperimentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One experiment of [recipeId], or null once it is deleted.

  HistoryExperimentProvider call(
    RecipeId recipeId,
    ExperimentId experimentId,
  ) => HistoryExperimentProvider._(
    argument: (recipeId, experimentId),
    from: this,
  );

  @override
  String toString() => r'historyExperimentProvider';
}

/// One past version of [recipeId], or null once it is gone.

@ProviderFor(historyVersion)
final historyVersionProvider = HistoryVersionFamily._();

/// One past version of [recipeId], or null once it is gone.

final class HistoryVersionProvider
    extends
        $FunctionalProvider<
          AsyncValue<RecipeVersion?>,
          AsyncValue<RecipeVersion?>,
          AsyncValue<RecipeVersion?>
        >
    with $Provider<AsyncValue<RecipeVersion?>> {
  /// One past version of [recipeId], or null once it is gone.
  HistoryVersionProvider._({
    required HistoryVersionFamily super.from,
    required (RecipeId, RecipeVersionId) super.argument,
  }) : super(
         retry: null,
         name: r'historyVersionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$historyVersionHash();

  @override
  String toString() {
    return r'historyVersionProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<RecipeVersion?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<RecipeVersion?> create(Ref ref) {
    final argument = this.argument as (RecipeId, RecipeVersionId);
    return historyVersion(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<RecipeVersion?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<RecipeVersion?>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HistoryVersionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$historyVersionHash() => r'c01a0af76b627877d0917334789d401f8371d36c';

/// One past version of [recipeId], or null once it is gone.

final class HistoryVersionFamily extends $Family
    with
        $FunctionalFamilyOverride<
          AsyncValue<RecipeVersion?>,
          (RecipeId, RecipeVersionId)
        > {
  HistoryVersionFamily._()
    : super(
        retry: null,
        name: r'historyVersionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One past version of [recipeId], or null once it is gone.

  HistoryVersionProvider call(RecipeId recipeId, RecipeVersionId versionId) =>
      HistoryVersionProvider._(argument: (recipeId, versionId), from: this);

  @override
  String toString() => r'historyVersionProvider';
}

/// What the recipe looked like at version [versionId].

@ProviderFor(versionSnapshot)
final versionSnapshotProvider = VersionSnapshotFamily._();

/// What the recipe looked like at version [versionId].

final class VersionSnapshotProvider
    extends
        $FunctionalProvider<
          AsyncValue<RecipeSnapshot?>,
          RecipeSnapshot?,
          FutureOr<RecipeSnapshot?>
        >
    with $FutureModifier<RecipeSnapshot?>, $FutureProvider<RecipeSnapshot?> {
  /// What the recipe looked like at version [versionId].
  VersionSnapshotProvider._({
    required VersionSnapshotFamily super.from,
    required RecipeVersionId super.argument,
  }) : super(
         retry: null,
         name: r'versionSnapshotProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$versionSnapshotHash();

  @override
  String toString() {
    return r'versionSnapshotProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RecipeSnapshot?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RecipeSnapshot?> create(Ref ref) {
    final argument = this.argument as RecipeVersionId;
    return versionSnapshot(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VersionSnapshotProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$versionSnapshotHash() => r'6f8504e7bcc59d1ff87a7419915f6699725a3dec';

/// What the recipe looked like at version [versionId].

final class VersionSnapshotFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RecipeSnapshot?>, RecipeVersionId> {
  VersionSnapshotFamily._()
    : super(
        retry: null,
        name: r'versionSnapshotProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What the recipe looked like at version [versionId].

  VersionSnapshotProvider call(RecipeVersionId versionId) =>
      VersionSnapshotProvider._(argument: versionId, from: this);

  @override
  String toString() => r'versionSnapshotProvider';
}
