import 'package:go_router/go_router.dart';
import 'package:sousvite/features/feedback/presentation/feedback_screen.dart';

/// Routes owned by the feedback feature: the bug report and suggestion form.
abstract final class FeedbackRoutes() {
  static const path = '/feedback';

  static final List<RouteBase> routes = [
    GoRoute(path: path, builder: (context, state) => const FeedbackScreen()),
  ];
}
