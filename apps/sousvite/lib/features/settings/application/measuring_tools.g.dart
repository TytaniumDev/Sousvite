// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measuring_tools.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The measuring cups and spoons the user owns: the ones they saved, or
/// [defaultMeasuringTools] until they change any.

@ProviderFor(ownedMeasuringTools)
final ownedMeasuringToolsProvider = OwnedMeasuringToolsProvider._();

/// The measuring cups and spoons the user owns: the ones they saved, or
/// [defaultMeasuringTools] until they change any.

final class OwnedMeasuringToolsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MeasuringTool>>,
          List<MeasuringTool>,
          Stream<List<MeasuringTool>>
        >
    with
        $FutureModifier<List<MeasuringTool>>,
        $StreamProvider<List<MeasuringTool>> {
  /// The measuring cups and spoons the user owns: the ones they saved, or
  /// [defaultMeasuringTools] until they change any.
  OwnedMeasuringToolsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ownedMeasuringToolsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ownedMeasuringToolsHash();

  @$internal
  @override
  $StreamProviderElement<List<MeasuringTool>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MeasuringTool>> create(Ref ref) {
    return ownedMeasuringTools(ref);
  }
}

String _$ownedMeasuringToolsHash() =>
    r'0fab3289a8c17a248ad5c64b558580701a9349b1';

/// Changes which measuring tools the user owns.

@ProviderFor(MeasuringToolsController)
final measuringToolsControllerProvider = MeasuringToolsControllerProvider._();

/// Changes which measuring tools the user owns.
final class MeasuringToolsControllerProvider
    extends $NotifierProvider<MeasuringToolsController, void> {
  /// Changes which measuring tools the user owns.
  MeasuringToolsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'measuringToolsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$measuringToolsControllerHash();

  @$internal
  @override
  MeasuringToolsController create() => MeasuringToolsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$measuringToolsControllerHash() =>
    r'db2e2c260c8cd0f23086ad4b1fb8fb878b629112';

/// Changes which measuring tools the user owns.

abstract class _$MeasuringToolsController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
