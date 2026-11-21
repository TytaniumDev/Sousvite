import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feedback_capture.g.dart';

/// Whether the app shows the capture bar, which lets the user go to the
/// screen a report is about and take a screenshot of it.
@Riverpod(keepAlive: true)
class FeedbackCapture() extends _$FeedbackCapture {
  @override
  bool build() => false;

  void start() => state = true;

  void stop() => state = false;
}
