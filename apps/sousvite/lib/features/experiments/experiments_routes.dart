import 'package:domain/domain.dart';
import 'package:go_router/go_router.dart';
import 'package:sousvite/features/experiments/presentation/experiment_screen.dart';
import 'package:sousvite/features/experiments/presentation/history_screen.dart';
import 'package:sousvite/features/experiments/presentation/version_screen.dart';

/// Routes owned by the experiments feature. Recipe experiments and history (PRD
/// 7.11).
abstract final class ExperimentsRoutes() {
  /// A recipe's history timeline.
  static const path = '/history/:recipeId';

  /// One experiment of a recipe.
  static const experimentPath = '$path/experiments/:experimentId';

  /// One past version of a recipe.
  static const versionPath = '$path/versions/:versionId';

  /// The location of [recipeId]'s history, for `context.go` and
  /// `context.push`.
  static String location(RecipeId recipeId) =>
      path.replaceFirst(':recipeId', Uri.encodeComponent(recipeId.value));

  /// The location of one experiment.
  static String experimentLocation(
    RecipeId recipeId,
    ExperimentId experimentId,
  ) =>
      '${location(recipeId)}/experiments/'
      '${Uri.encodeComponent(experimentId.value)}';

  /// The location of one past version.
  static String versionLocation(RecipeId recipeId, RecipeVersionId versionId) =>
      '${location(recipeId)}/versions/${Uri.encodeComponent(versionId.value)}';

  static final List<RouteBase> routes = [
    GoRoute(
      path: path,
      builder: (context, state) =>
          HistoryScreen(recipeId: RecipeId(state.pathParameters['recipeId']!)),
      routes: [
        GoRoute(
          path: 'experiments/:experimentId',
          builder: (context, state) => ExperimentScreen(
            recipeId: RecipeId(state.pathParameters['recipeId']!),
            experimentId: ExperimentId(state.pathParameters['experimentId']!),
          ),
        ),
        GoRoute(
          path: 'versions/:versionId',
          builder: (context, state) => VersionScreen(
            recipeId: RecipeId(state.pathParameters['recipeId']!),
            versionId: RecipeVersionId(state.pathParameters['versionId']!),
          ),
        ),
      ],
    ),
  ];
}
