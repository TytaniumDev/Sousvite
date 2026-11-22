import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/feedback/application/feedback_draft.dart';
import 'package:sousvite/features/feedback/feedback.dart';
import 'package:sousvite/features/feedback/presentation/feedback_screen.dart';

import '../../../helpers/helpers.dart';

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      initialLocation: '/problem',
      routes: [
        GoRoute(
          path: '/problem',
          builder: (_, _) => const PageScaffold(body: Text('Problem screen')),
        ),
        ...FeedbackRoutes.routes,
      ],
    );
    addTearDown(router.dispose);
  });

  group(FeedbackButton, () {
    testWidgets('screenshots the page and opens the form', (tester) async {
      await tester.pumpRouterApp(
        router,
        builder: (context, child) => FeedbackCaptureLayer(
          router: router,
          child: PageActions(actions: const [FeedbackButton()], child: child!),
        ),
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Navigator)),
      );

      // Encoding the image is real asynchronous work.
      await tester.runAsync(() async {
        await tester.tap(find.byTooltip('Send feedback'));
        await Future<void>.delayed(const Duration(milliseconds: 500));
      });
      await tester.pumpAndSettle();

      final draft = container.read(feedbackDraftProvider);
      expect(draft.screenshot, isNotEmpty);
      expect(draft.location, '/problem');
      expect(find.byType(FeedbackScreen), findsOneWidget);
      // The form has no button that opens itself.
      expect(find.byTooltip('Send feedback'), findsNothing);
    });

    testWidgets('opens the form without a capture layer', (tester) async {
      await tester.pumpRouterApp(
        router,
        builder: (context, child) =>
            PageActions(actions: const [FeedbackButton()], child: child!),
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Navigator)),
      );

      await tester.tap(find.byTooltip('Send feedback'));
      await tester.pumpAndSettle();

      expect(find.byType(FeedbackScreen), findsOneWidget);
      expect(container.read(feedbackDraftProvider).screenshot, isNull);
    });
  });
}
