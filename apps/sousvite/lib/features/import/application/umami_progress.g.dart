// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'umami_progress.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The running Umami import's progress, or null when none is running.
/// `UmamiActions` reports into it.

@ProviderFor(UmamiProgress)
final umamiProgressProvider = UmamiProgressProvider._();

/// The running Umami import's progress, or null when none is running.
/// `UmamiActions` reports into it.
final class UmamiProgressProvider
    extends $NotifierProvider<UmamiProgress, UmamiImportProgress?> {
  /// The running Umami import's progress, or null when none is running.
  /// `UmamiActions` reports into it.
  UmamiProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'umamiProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$umamiProgressHash();

  @$internal
  @override
  UmamiProgress create() => UmamiProgress();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UmamiImportProgress? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UmamiImportProgress?>(value),
    );
  }
}

String _$umamiProgressHash() => r'bc59892f4f3e0a3e859502b53fecb319af40a170';

/// The running Umami import's progress, or null when none is running.
/// `UmamiActions` reports into it.

abstract class _$UmamiProgress extends $Notifier<UmamiImportProgress?> {
  UmamiImportProgress? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UmamiImportProgress?, UmamiImportProgress?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UmamiImportProgress?, UmamiImportProgress?>,
              UmamiImportProgress?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
