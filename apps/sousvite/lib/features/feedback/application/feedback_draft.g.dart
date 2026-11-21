// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_draft.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The report the user is writing. Kept for the app's lifetime, so the text
/// survives while the form is closed to capture a screen.

@ProviderFor(FeedbackDraft)
final feedbackDraftProvider = FeedbackDraftProvider._();

/// The report the user is writing. Kept for the app's lifetime, so the text
/// survives while the form is closed to capture a screen.
final class FeedbackDraftProvider
    extends $NotifierProvider<FeedbackDraft, FeedbackReport> {
  /// The report the user is writing. Kept for the app's lifetime, so the text
  /// survives while the form is closed to capture a screen.
  FeedbackDraftProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedbackDraftProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedbackDraftHash();

  @$internal
  @override
  FeedbackDraft create() => FeedbackDraft();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedbackReport value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedbackReport>(value),
    );
  }
}

String _$feedbackDraftHash() => r'b1d36c84e0950eeccfc0bc7b56ee993fa89193f2';

/// The report the user is writing. Kept for the app's lifetime, so the text
/// survives while the form is closed to capture a screen.

abstract class _$FeedbackDraft extends $Notifier<FeedbackReport> {
  FeedbackReport build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FeedbackReport, FeedbackReport>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FeedbackReport, FeedbackReport>,
              FeedbackReport,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
