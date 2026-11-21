import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sousvite/app/services/error_reporter.dart';
import 'package:sousvite/app/services/feedback_service.dart';

class _MockHub() extends Mock implements Hub;

void main() {
  setUpAll(() => registerFallbackValue(SentryFeedback(message: '')));

  group(SentryFeedbackService, () {
    late _MockHub hub;

    setUp(() {
      hub = _MockHub();
      when(() => hub.captureFeedback(any(), hint: any(named: 'hint')))
          .thenAnswer((_) async => const SentryId.empty());
    });

    List<Object?> captured() => verify(
      () => hub.captureFeedback(captureAny(), hint: captureAny(named: 'hint')),
    ).captured;

    test('sends the message, email, location, and screenshot', () async {
      final png = Uint8List.fromList([1, 2, 3]);

      await SentryFeedbackService(hub).send(
        FeedbackReport(
          message: 'Fix all matched nothing',
          email: 'cook@example.com',
          screenshot: png,
          location: '/library/folders/f1',
        ),
      );

      final [feedback as SentryFeedback, hint as Hint] = captured();
      expect(feedback.message, 'Fix all matched nothing');
      expect(feedback.contactEmail, 'cook@example.com');
      expect(feedback.url, '/library/folders/f1');
      expect(hint.screenshot?.bytes, png);
    });

    test('leaves out an empty email and a missing screenshot', () async {
      await SentryFeedbackService(hub)
          .send(const FeedbackReport(message: 'An idea'));

      final [feedback as SentryFeedback, hint] = captured();
      expect(feedback.contactEmail, isNull);
      expect(feedback.url, isNull);
      expect(hint, isNull);
    });
  });

  group(DebugFeedbackService, () {
    test('prints the report', () async {
      final printed = <String?>[];
      final original = debugPrint;
      debugPrint = (message, {wrapWidth}) => printed.add(message);
      addTearDown(() => debugPrint = original);

      await const DebugFeedbackService().send(
        const FeedbackReport(message: 'An idea', location: '/settings'),
      );
      await const DebugFeedbackService().send(
        const FeedbackReport(message: 'Another'),
      );

      expect(printed, [
        'Feedback: An idea (at /settings)',
        'Feedback: Another',
      ]);
    });
  });

  group('feedbackServiceProvider', () {
    test('prints to the console when no DSN is set', () {
      final container = ProviderContainer.test(
        overrides: [sentryDsnProvider.overrideWithValue('')],
      );

      expect(
        container.read(feedbackServiceProvider),
        isA<DebugFeedbackService>(),
      );
    });

    test('uses Sentry when a DSN is set', () {
      final container = ProviderContainer.test(
        overrides: [
          sentryDsnProvider.overrideWithValue('https://key@sentry.invalid/1'),
        ],
      );

      expect(
        container.read(feedbackServiceProvider),
        isA<SentryFeedbackService>(),
      );
    });
  });
}
