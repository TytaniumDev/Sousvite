// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in_callout.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// When the user last hid the library's sign-in card, or null.

@ProviderFor(SignInCalloutDismissal)
final signInCalloutDismissalProvider = SignInCalloutDismissalProvider._();

/// When the user last hid the library's sign-in card, or null.
final class SignInCalloutDismissalProvider
    extends $AsyncNotifierProvider<SignInCalloutDismissal, DateTime?> {
  /// When the user last hid the library's sign-in card, or null.
  SignInCalloutDismissalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInCalloutDismissalProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInCalloutDismissalHash();

  @$internal
  @override
  SignInCalloutDismissal create() => SignInCalloutDismissal();
}

String _$signInCalloutDismissalHash() =>
    r'03e1ca02447111b9104d18108981d8876fefe9c7';

/// When the user last hid the library's sign-in card, or null.

abstract class _$SignInCalloutDismissal extends $AsyncNotifier<DateTime?> {
  FutureOr<DateTime?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DateTime?>, DateTime?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DateTime?>, DateTime?>,
              AsyncValue<DateTime?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Whether to invite the user to sign in for free backup and sync: only
/// while signed out, in builds that can sign in (ENGINEERING.md §10).

@ProviderFor(signInInviteAvailable)
final signInInviteAvailableProvider = SignInInviteAvailableProvider._();

/// Whether to invite the user to sign in for free backup and sync: only
/// while signed out, in builds that can sign in (ENGINEERING.md §10).

final class SignInInviteAvailableProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether to invite the user to sign in for free backup and sync: only
  /// while signed out, in builds that can sign in (ENGINEERING.md §10).
  SignInInviteAvailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInInviteAvailableProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInInviteAvailableHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return signInInviteAvailable(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$signInInviteAvailableHash() =>
    r'cc6ab142fd527bfd9764174bc663f5690f964679';

/// Whether the library shows its sign-in card: invited, and not hidden in
/// the last 30 days.

@ProviderFor(signInCalloutVisible)
final signInCalloutVisibleProvider = SignInCalloutVisibleProvider._();

/// Whether the library shows its sign-in card: invited, and not hidden in
/// the last 30 days.

final class SignInCalloutVisibleProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the library shows its sign-in card: invited, and not hidden in
  /// the last 30 days.
  SignInCalloutVisibleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInCalloutVisibleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInCalloutVisibleHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return signInCalloutVisible(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$signInCalloutVisibleHash() =>
    r'e208b748b46b2fcf9a4f4ec117cf1c70ded456e1';
