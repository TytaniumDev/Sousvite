// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_system_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How amounts are shown in recipes that have no choice of their own
/// (PRD 7.6). As written until settings load.

@ProviderFor(UnitSystemController)
final unitSystemControllerProvider = UnitSystemControllerProvider._();

/// How amounts are shown in recipes that have no choice of their own
/// (PRD 7.6). As written until settings load.
final class UnitSystemControllerProvider
    extends $NotifierProvider<UnitSystemController, UnitSystem> {
  /// How amounts are shown in recipes that have no choice of their own
  /// (PRD 7.6). As written until settings load.
  UnitSystemControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unitSystemControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unitSystemControllerHash();

  @$internal
  @override
  UnitSystemController create() => UnitSystemController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnitSystem value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnitSystem>(value),
    );
  }
}

String _$unitSystemControllerHash() =>
    r'48ec8361a92415c9a65a0541959040d52a1c83e0';

/// How amounts are shown in recipes that have no choice of their own
/// (PRD 7.6). As written until settings load.

abstract class _$UnitSystemController extends $Notifier<UnitSystem> {
  UnitSystem build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UnitSystem, UnitSystem>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UnitSystem, UnitSystem>,
              UnitSystem,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
