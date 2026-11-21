import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/services/feedback_service.dart';

part 'feedback_draft.g.dart';

/// The report the user is writing. Kept for the app's lifetime, so the text
/// survives while the form is closed to capture a screen.
@Riverpod(keepAlive: true)
class FeedbackDraft() extends _$FeedbackDraft {
  @override
  FeedbackReport build() => const FeedbackReport();

  void updateMessage(String message) =>
      state = state.copyWith(message: message);

  void updateEmail(String email) => state = state.copyWith(email: email);

  /// Attaches [png], captured at [location], in place of any earlier one.
  void attachScreenshot(Uint8List png, {required String location}) =>
      state = state.copyWith(screenshot: png, location: location);

  void removeScreenshot() =>
      state = state.copyWith(screenshot: null, location: null);

  /// Sends the report, trimmed, and starts a new one. Keeps the draft if
  /// sending fails, so the user can try again.
  Future<void> send() async {
    final report = state.copyWith(
      message: state.message.trim(),
      email: state.email.trim(),
    );
    await ref.read(feedbackServiceProvider).send(report);
    state = const FeedbackReport();
  }
}
