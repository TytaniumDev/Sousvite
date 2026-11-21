import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/services/feedback_service.dart';
import 'package:sousvite/features/feedback/application/feedback_draft.dart';

import '../fakes.dart';

void main() {
  group(FeedbackDraft, () {
    late FakeFeedbackService service;
    late ProviderContainer container;

    setUp(() {
      service = FakeFeedbackService();
      container = ProviderContainer.test(
        overrides: [feedbackServiceProvider.overrideWithValue(service)],
      );
    });

    FeedbackDraft draft() => container.read(feedbackDraftProvider.notifier);
    FeedbackReport state() => container.read(feedbackDraftProvider);
    final png = Uint8List.fromList([1, 2, 3]);

    test('starts empty', () {
      expect(state(), const FeedbackReport());
    });

    test('keeps the message and email', () {
      draft()
        ..updateMessage('Fix all matched nothing')
        ..updateEmail('cook@example.com');

      expect(state().message, 'Fix all matched nothing');
      expect(state().email, 'cook@example.com');
    });

    test('attaches and removes a screenshot with its location', () {
      draft().attachScreenshot(png, location: '/library');

      expect(state().screenshot, png);
      expect(state().location, '/library');

      draft().removeScreenshot();

      expect(state().screenshot, isNull);
      expect(state().location, isNull);
    });

    test('sends the trimmed report and starts a new one', () async {
      draft()
        ..updateMessage('  Fix all matched nothing \n')
        ..updateEmail(' cook@example.com ')
        ..attachScreenshot(png, location: '/library');

      await draft().send();

      expect(service.sent, [
        FeedbackReport(
          message: 'Fix all matched nothing',
          email: 'cook@example.com',
          screenshot: png,
          location: '/library',
        ),
      ]);
      expect(state(), const FeedbackReport());
    });

    test('keeps the draft when sending fails', () async {
      service.error = Exception('offline');
      draft().updateMessage('Fix all matched nothing');

      await expectLater(draft().send(), throwsException);

      expect(state().message, 'Fix all matched nothing');
    });
  });
}
