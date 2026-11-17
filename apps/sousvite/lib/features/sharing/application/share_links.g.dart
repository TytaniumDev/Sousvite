// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_links.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The copy invite link made for [recipeId] on the share screen: null until
/// made, loading while it's made, or the error.

@ProviderFor(CopyLink)
final copyLinkProvider = CopyLinkFamily._();

/// The copy invite link made for [recipeId] on the share screen: null until
/// made, loading while it's made, or the error.
final class CopyLinkProvider extends $AsyncNotifierProvider<CopyLink, Uri?> {
  /// The copy invite link made for [recipeId] on the share screen: null until
  /// made, loading while it's made, or the error.
  CopyLinkProvider._({
    required CopyLinkFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'copyLinkProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$copyLinkHash();

  @override
  String toString() {
    return r'copyLinkProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CopyLink create() => CopyLink();

  @override
  bool operator ==(Object other) {
    return other is CopyLinkProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$copyLinkHash() => r'9b0e360d018d3f5e5deecf36630f9ae3493cc136';

/// The copy invite link made for [recipeId] on the share screen: null until
/// made, loading while it's made, or the error.

final class CopyLinkFamily extends $Family
    with
        $ClassFamilyOverride<
          CopyLink,
          AsyncValue<Uri?>,
          Uri?,
          FutureOr<Uri?>,
          RecipeId
        > {
  CopyLinkFamily._()
    : super(
        retry: null,
        name: r'copyLinkProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The copy invite link made for [recipeId] on the share screen: null until
  /// made, loading while it's made, or the error.

  CopyLinkProvider call(RecipeId recipeId) =>
      CopyLinkProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'copyLinkProvider';
}

/// The copy invite link made for [recipeId] on the share screen: null until
/// made, loading while it's made, or the error.

abstract class _$CopyLink extends $AsyncNotifier<Uri?> {
  late final _$args = ref.$arg as RecipeId;
  RecipeId get recipeId => _$args;

  FutureOr<Uri?> build(RecipeId recipeId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Uri?>, Uri?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Uri?>, Uri?>,
              AsyncValue<Uri?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// The view-only link id published for [recipeId] on the share screen, null
/// until published or after it's turned off.

@ProviderFor(ViewOnlyLink)
final viewOnlyLinkProvider = ViewOnlyLinkFamily._();

/// The view-only link id published for [recipeId] on the share screen, null
/// until published or after it's turned off.
final class ViewOnlyLinkProvider
    extends $AsyncNotifierProvider<ViewOnlyLink, String?> {
  /// The view-only link id published for [recipeId] on the share screen, null
  /// until published or after it's turned off.
  ViewOnlyLinkProvider._({
    required ViewOnlyLinkFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'viewOnlyLinkProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$viewOnlyLinkHash();

  @override
  String toString() {
    return r'viewOnlyLinkProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ViewOnlyLink create() => ViewOnlyLink();

  @override
  bool operator ==(Object other) {
    return other is ViewOnlyLinkProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$viewOnlyLinkHash() => r'f5bd758ac285d1f2e32b2c1539e350b4a63573d3';

/// The view-only link id published for [recipeId] on the share screen, null
/// until published or after it's turned off.

final class ViewOnlyLinkFamily extends $Family
    with
        $ClassFamilyOverride<
          ViewOnlyLink,
          AsyncValue<String?>,
          String?,
          FutureOr<String?>,
          RecipeId
        > {
  ViewOnlyLinkFamily._()
    : super(
        retry: null,
        name: r'viewOnlyLinkProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The view-only link id published for [recipeId] on the share screen, null
  /// until published or after it's turned off.

  ViewOnlyLinkProvider call(RecipeId recipeId) =>
      ViewOnlyLinkProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'viewOnlyLinkProvider';
}

/// The view-only link id published for [recipeId] on the share screen, null
/// until published or after it's turned off.

abstract class _$ViewOnlyLink extends $AsyncNotifier<String?> {
  late final _$args = ref.$arg as RecipeId;
  RecipeId get recipeId => _$args;

  FutureOr<String?> build(RecipeId recipeId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
