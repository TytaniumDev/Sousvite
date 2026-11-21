import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/services/feedback_service.dart';
import 'package:sousvite/features/feedback/application/feedback_capture.dart';
import 'package:sousvite/features/feedback/application/feedback_draft.dart';
import 'package:sousvite/features/feedback/feedback.dart';
import 'package:sousvite/features/feedback/presentation/feedback_screen.dart';
import 'package:sousvite/features/feedback/presentation/screenshot_section.dart';
import 'package:sousvite/features/feedback/presentation/send_feedback_button.dart';

import '../../../helpers/helpers.dart';
import '../../../helpers/photos.dart';
import '../fakes.dart';

void main() {
  late FakeFeedbackService service;
  late GoRouter router;

  setUp(() {
    service = FakeFeedbackService();
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Problem screen')),
        ),
        ...FeedbackRoutes.routes,
      ],
    );
    addTearDown(router.dispose);
  });

  /// Shows the problem screen in a window tall enough for the whole form,
  /// and returns the app's providers.
  Future<ProviderContainer> pump(
    WidgetTester tester, {
    double width = 400,
  }) async {
    tester.setWindowWidth(width, height: 1600);
    await tester.pumpRouterApp(
      router,
      overrides: [feedbackServiceProvider.overrideWithValue(service)],
    );
    return ProviderScope.containerOf(tester.element(find.byType(Navigator)));
  }

  /// Opens the form on top of the problem screen, as Settings does.
  Future<void> openForm(WidgetTester tester) async {
    unawaited(router.push(FeedbackRoutes.path));
    await tester.pumpAndSettle();
  }

  final message = find.widgetWithText(TextField, 'Your feedback');
  final email = find.widgetWithText(TextField, 'Email (optional)');
  final send = find.widgetWithText(FilledButton, 'Send');

  group(FeedbackScreen, () {
    testWidgets('keeps the form to a short column on a wide window', (
      tester,
    ) async {
      await pump(tester, width: 1600);
      await openForm(tester);

      tester.expectInCenteredColumn(message, ReadingColumn.formWidth);
    });

    testWidgets('sends once there is a message, then closes', (tester) async {
      await pump(tester);
      await openForm(tester);

      expect(tester.widget<FilledButton>(send).onPressed, isNull);

      await tester.enterText(message, 'Fix all matched nothing');
      await tester.enterText(email, 'cook@example.com');
      await tester.pump();
      await tester.tap(send);
      await tester.pumpAndSettle();

      expect(service.sent.single.message, 'Fix all matched nothing');
      expect(service.sent.single.email, 'cook@example.com');
      expect(find.text('Feedback sent. Thanks.'), findsOneWidget);
      expect(find.text('Problem screen'), findsOneWidget);
    });

    testWidgets('stays open and keeps the text when sending fails', (
      tester,
    ) async {
      service.error = Exception('offline');
      await pump(tester);
      await openForm(tester);

      await tester.enterText(message, 'Fix all matched nothing');
      await tester.pump();
      await tester.tap(send);
      await tester.pumpAndSettle();

      expect(
        find.text("Couldn't send your feedback. Try again."),
        findsOneWidget,
      );
      expect(find.byType(FeedbackScreen), findsOneWidget);
      expect(find.text('Fix all matched nothing'), findsOneWidget);
      expect(tester.widget<FilledButton>(send).onPressed, isNotNull);
    });

    testWidgets('keeps the text while the form is closed', (tester) async {
      final container = await pump(tester);
      container.read(feedbackDraftProvider.notifier)
        ..updateMessage('Fix all matched nothing')
        ..updateEmail('cook@example.com');
      await openForm(tester);

      expect(find.text('Fix all matched nothing'), findsOneWidget);
      expect(find.text('cook@example.com'), findsOneWidget);
    });

    testWidgets('clears the fields when the draft is sent elsewhere', (
      tester,
    ) async {
      final container = await pump(tester);
      await openForm(tester);
      await tester.enterText(message, 'Fix all matched nothing');

      await container.read(feedbackDraftProvider.notifier).send();
      await tester.pump();

      expect(find.text('Fix all matched nothing'), findsNothing);
    });

    testWidgets('typing rebuilds only the send button, and only when the '
        'message stops being empty', (tester) async {
      final builds = BuildCounter.start();
      await pump(tester);
      await openForm(tester);
      builds.reset();

      await tester.enterText(message, 'F');
      await tester.pump();
      await tester.enterText(message, 'Fi');
      await tester.pump();

      expect(builds.of<SendFeedbackButton>(), 1);
      expect(builds.of<ScreenshotSection>(), 0);
      expect(builds.of<FeedbackScreen>(), 0);
    });

    testWidgets('add a screenshot closes the form and starts a capture', (
      tester,
    ) async {
      final container = await pump(tester);
      await openForm(tester);

      await tester.tap(find.text('Add a screenshot'));
      await tester.pumpAndSettle();

      expect(container.read(feedbackCaptureProvider), isTrue);
      expect(find.text('Problem screen'), findsOneWidget);
    });

    testWidgets('shows a captured screenshot and removes it', (tester) async {
      final container = await pump(tester);
      container
          .read(feedbackDraftProvider.notifier)
          .attachScreenshot(testJpeg(), location: '/');
      await openForm(tester);

      expect(
        find.bySemanticsLabel('Screenshot to send with your feedback'),
        findsOneWidget,
      );
      expect(find.text('Add a screenshot'), findsNothing);

      await tester.tap(find.text('Remove screenshot'));
      await tester.pump();

      expect(container.read(feedbackDraftProvider).screenshot, isNull);
      expect(find.text('Add a screenshot'), findsOneWidget);
    });
  });
}
