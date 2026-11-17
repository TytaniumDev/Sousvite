// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the invite [inviteId] offers. Not retried: an expired or missing
/// invite stays that way, and the screen says so at once.

@ProviderFor(invitePreview)
final invitePreviewProvider = InvitePreviewFamily._();

/// What the invite [inviteId] offers. Not retried: an expired or missing
/// invite stays that way, and the screen says so at once.

final class InvitePreviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<InvitePreview>,
          InvitePreview,
          FutureOr<InvitePreview>
        >
    with $FutureModifier<InvitePreview>, $FutureProvider<InvitePreview> {
  /// What the invite [inviteId] offers. Not retried: an expired or missing
  /// invite stays that way, and the screen says so at once.
  InvitePreviewProvider._({
    required InvitePreviewFamily super.from,
    required String super.argument,
  }) : super(
         retry: _noRetry,
         name: r'invitePreviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$invitePreviewHash();

  @override
  String toString() {
    return r'invitePreviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<InvitePreview> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<InvitePreview> create(Ref ref) {
    final argument = this.argument as String;
    return invitePreview(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is InvitePreviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$invitePreviewHash() => r'6e270348434fb8bf9125c2d67b218db85b1221e0';

/// What the invite [inviteId] offers. Not retried: an expired or missing
/// invite stays that way, and the screen says so at once.

final class InvitePreviewFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<InvitePreview>, String> {
  InvitePreviewFamily._()
    : super(
        retry: _noRetry,
        name: r'invitePreviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What the invite [inviteId] offers. Not retried: an expired or missing
  /// invite stays that way, and the screen says so at once.

  InvitePreviewProvider call(String inviteId) =>
      InvitePreviewProvider._(argument: inviteId, from: this);

  @override
  String toString() => r'invitePreviewProvider';
}

/// Accepts the invite [inviteId]: loading while it runs, then the saved
/// copy's id (null before accepting or for a joint share), or the error.

@ProviderFor(InviteAcceptance)
final inviteAcceptanceProvider = InviteAcceptanceFamily._();

/// Accepts the invite [inviteId]: loading while it runs, then the saved
/// copy's id (null before accepting or for a joint share), or the error.
final class InviteAcceptanceProvider
    extends $AsyncNotifierProvider<InviteAcceptance, RecipeId?> {
  /// Accepts the invite [inviteId]: loading while it runs, then the saved
  /// copy's id (null before accepting or for a joint share), or the error.
  InviteAcceptanceProvider._({
    required InviteAcceptanceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'inviteAcceptanceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$inviteAcceptanceHash();

  @override
  String toString() {
    return r'inviteAcceptanceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  InviteAcceptance create() => InviteAcceptance();

  @override
  bool operator ==(Object other) {
    return other is InviteAcceptanceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inviteAcceptanceHash() => r'02fa35925d5513324b5cb49c1e36efb40a531b40';

/// Accepts the invite [inviteId]: loading while it runs, then the saved
/// copy's id (null before accepting or for a joint share), or the error.

final class InviteAcceptanceFamily extends $Family
    with
        $ClassFamilyOverride<
          InviteAcceptance,
          AsyncValue<RecipeId?>,
          RecipeId?,
          FutureOr<RecipeId?>,
          String
        > {
  InviteAcceptanceFamily._()
    : super(
        retry: null,
        name: r'inviteAcceptanceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Accepts the invite [inviteId]: loading while it runs, then the saved
  /// copy's id (null before accepting or for a joint share), or the error.

  InviteAcceptanceProvider call(String inviteId) =>
      InviteAcceptanceProvider._(argument: inviteId, from: this);

  @override
  String toString() => r'inviteAcceptanceProvider';
}

/// Accepts the invite [inviteId]: loading while it runs, then the saved
/// copy's id (null before accepting or for a joint share), or the error.

abstract class _$InviteAcceptance extends $AsyncNotifier<RecipeId?> {
  late final _$args = ref.$arg as String;
  String get inviteId => _$args;

  FutureOr<RecipeId?> build(String inviteId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<RecipeId?>, RecipeId?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<RecipeId?>, RecipeId?>,
              AsyncValue<RecipeId?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
