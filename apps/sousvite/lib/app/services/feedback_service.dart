import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sousvite/app/services/error_reporter.dart';

part 'feedback_service.freezed.dart';
part 'feedback_service.g.dart';

/// A bug report or suggestion the user writes in the app.
@freezed
abstract class FeedbackReport with _$FeedbackReport {
  const factory({
    /// What happened, or the idea, in the user's words.
    @Default('') String message,

    /// Where to reply, if the user typed it. Empty for none.
    @Default('') String email,

    /// A PNG of the screen the report is about, if the user captured one.
    Uint8List? screenshot,

    /// The app location of [screenshot], such as `/library/folders/<id>`.
    String? location,
  }) = _FeedbackReport;
}

/// Sends what users report from the app.
///
/// [SentryFeedbackService] when the build passes a Sentry DSN, otherwise
/// [DebugFeedbackService], as for [ErrorReporter].
abstract interface class FeedbackService() {
  Future<void> send(FeedbackReport report);
}

/// Prints reports to the debug console. Used when no Sentry DSN is set, as
/// in local runs, tests, and CI.
class const DebugFeedbackService() implements FeedbackService {
  @override
  Future<void> send(FeedbackReport report) async {
    debugPrint(
      'Feedback: ${report.message}'
      '${report.location == null ? '' : ' (at ${report.location})'}',
    );
  }
}

/// Sends reports to Sentry's User Feedback, with the screenshot attached.
class const SentryFeedbackService(
  /// Where reports go. [HubAdapter] in the app; a fake in tests.
  final Hub _hub,
) implements FeedbackService {
  @override
  Future<void> send(FeedbackReport report) async {
    final screenshot = report.screenshot;
    await _hub.captureFeedback(
      SentryFeedback(
        message: report.message,
        contactEmail: report.email.isEmpty ? null : report.email,
        url: report.location,
      ),
      hint: screenshot == null
          ? null
          : Hint.withScreenshot(
              SentryAttachment.fromScreenshotData(screenshot),
            ),
    );
  }
}

@Riverpod(keepAlive: true)
FeedbackService feedbackService(Ref ref) => ref.watch(sentryDsnProvider).isEmpty
    ? const DebugFeedbackService()
    : SentryFeedbackService(HubAdapter());
