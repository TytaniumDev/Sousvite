import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/feedback/application/feedback_capture.dart';
import 'package:sousvite/features/feedback/application/feedback_draft.dart';
import 'package:sousvite/features/feedback/feedback.dart';
import 'package:sousvite/features/feedback/presentation/feedback_screen.dart';

import '../../../helpers/helpers.dart';

class const _ProblemScreen() extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Text('Problem screen'));
}

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      initialLocation: '/problem',
      routes: [
        GoRoute(path: '/problem', builder: (_, _) => const _ProblemScreen()),
        ...FeedbackRoutes.routes,
      ],
    );
    addTearDown(router.dispose);
  });

  /// Shows the app with the capture layer, and returns its providers.
  Future<ProviderContainer> pump(WidgetTester tester) async {
    await tester.pumpRouterApp(
      router,
      builder: (context, child) =>
          FeedbackCaptureLayer(router: router, child: child!),
    );
    return ProviderScope.containerOf(tester.element(find.byType(Navigator)));
  }

  group(FeedbackCaptureLayer, () {
    testWidgets('shows the capture bar only during a capture, without '
        'rebuilding the app', (tester) async {
      final builds = BuildCounter.start();
      final container = await pump(tester);
      builds.reset();

      expect(find.text('Capture'), findsNothing);

      container.read(feedbackCaptureProvider.notifier).start();
      await tester.pump();

      expect(find.text('Capture'), findsOneWidget);
      expect(builds.of<_ProblemScreen>(), 0);
    });

    testWidgets('captures the current screen and reopens the form', (
      tester,
    ) async {
      final container = await pump(tester);
      container.read(feedbackCaptureProvider.notifier).start();
      await tester.pump();

      // Encoding the image is real asynchronous work.
      await tester.runAsync(() async {
        await tester.tap(find.text('Capture'));
        await Future<void>.delayed(const Duration(milliseconds: 500));
      });
      await tester.pumpAndSettle();

      final draft = container.read(feedbackDraftProvider);
      expect(draft.screenshot, isNotEmpty);
      expect(draft.location, '/problem');
      expect(container.read(feedbackCaptureProvider), isFalse);
      expect(find.byType(FeedbackScreen), findsOneWidget);
      expect(find.text('Capture'), findsNothing);
    });

    testWidgets('cancel reopens the form without a screenshot', (tester) async {
      final container = await pump(tester);
      container.read(feedbackCaptureProvider.notifier).start();
      await tester.pump();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(container.read(feedbackDraftProvider).screenshot, isNull);
      expect(container.read(feedbackCaptureProvider), isFalse);
      expect(find.byType(FeedbackScreen), findsOneWidget);
    });
  });
}
