// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_capture.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the app shows the capture bar, which lets the user go to the
/// screen a report is about and take a screenshot of it.

@ProviderFor(FeedbackCapture)
final feedbackCaptureProvider = FeedbackCaptureProvider._();

/// Whether the app shows the capture bar, which lets the user go to the
/// screen a report is about and take a screenshot of it.
final class FeedbackCaptureProvider
    extends $NotifierProvider<FeedbackCapture, bool> {
  /// Whether the app shows the capture bar, which lets the user go to the
  /// screen a report is about and take a screenshot of it.
  FeedbackCaptureProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedbackCaptureProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedbackCaptureHash();

  @$internal
  @override
  FeedbackCapture create() => FeedbackCapture();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$feedbackCaptureHash() => r'672ea81d0ca148f59ba52dd957c2c7ec834336ea';

/// Whether the app shows the capture bar, which lets the user go to the
/// screen a report is about and take a screenshot of it.

abstract class _$FeedbackCapture extends $Notifier<bool> {
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
