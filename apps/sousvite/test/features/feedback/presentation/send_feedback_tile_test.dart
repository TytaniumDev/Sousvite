import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/feedback/application/feedback_capture.dart';
import 'package:sousvite/features/feedback/feedback.dart';
import 'package:sousvite/features/feedback/presentation/feedback_screen.dart';

import '../../../helpers/helpers.dart';

void main() {
  group(SendFeedbackTile, () {
    testWidgets('opens the form and ends a capture', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: SendFeedbackTile()),
          ),
          ...FeedbackRoutes.routes,
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Navigator)),
      )..read(feedbackCaptureProvider.notifier).start();

      expect(find.text('Report a bug or suggest an idea'), findsOneWidget);

      await tester.tap(find.text('Send feedback'));
      await tester.pumpAndSettle();

      expect(find.byType(FeedbackScreen), findsOneWidget);
      expect(container.read(feedbackCaptureProvider), isFalse);
    });
  });
}
