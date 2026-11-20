// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jarred_garlic_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether garlic cloves are shown as spoons of jarred minced garlic. Off
/// until settings load. Tapping a clove amount in any recipe flips it for
/// every recipe.

@ProviderFor(JarredGarlicController)
final jarredGarlicControllerProvider = JarredGarlicControllerProvider._();

/// Whether garlic cloves are shown as spoons of jarred minced garlic. Off
/// until settings load. Tapping a clove amount in any recipe flips it for
/// every recipe.
final class JarredGarlicControllerProvider
    extends $NotifierProvider<JarredGarlicController, bool> {
  /// Whether garlic cloves are shown as spoons of jarred minced garlic. Off
  /// until settings load. Tapping a clove amount in any recipe flips it for
  /// every recipe.
  JarredGarlicControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jarredGarlicControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jarredGarlicControllerHash();

  @$internal
  @override
  JarredGarlicController create() => JarredGarlicController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$jarredGarlicControllerHash() =>
    r'910d36feae0355ec13becaeb890491cfe7160b91';

/// Whether garlic cloves are shown as spoons of jarred minced garlic. Off
/// until settings load. Tapping a clove amount in any recipe flips it for
/// every recipe.

abstract class _$JarredGarlicController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
