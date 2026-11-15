// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(experimentActions)
final experimentActionsProvider = ExperimentActionsProvider._();

final class ExperimentActionsProvider
    extends
        $FunctionalProvider<
          ExperimentActions,
          ExperimentActions,
          ExperimentActions
        >
    with $Provider<ExperimentActions> {
  ExperimentActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'experimentActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$experimentActionsHash();

  @$internal
  @override
  $ProviderElement<ExperimentActions> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExperimentActions create(Ref ref) {
    return experimentActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExperimentActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExperimentActions>(value),
    );
  }
}

String _$experimentActionsHash() => r'903c57629d37cf9435b9cf47f2509487d7263386';
