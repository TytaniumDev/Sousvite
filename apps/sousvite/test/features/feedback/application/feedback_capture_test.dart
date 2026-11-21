import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/feedback/application/feedback_capture.dart';

void main() {
  group(FeedbackCapture, () {
    test('starts off, and turns on and off', () {
      final container = ProviderContainer.test();
      final capture = container.read(feedbackCaptureProvider.notifier);
      bool on() => container.read(feedbackCaptureProvider);

      expect(on(), isFalse);

      capture.start();
      expect(on(), isTrue);

      capture.stop();
      expect(on(), isFalse);
    });
  });
}
