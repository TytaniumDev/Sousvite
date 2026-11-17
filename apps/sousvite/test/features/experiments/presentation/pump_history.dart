import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/experiments/experiments.dart';
import 'package:sousvite/l10n/l10n.dart';

import '../../../helpers/fakes/fake_recipe_space_repository.dart';

/// Opens [location] in a router with the experiments routes, plus stand-in
/// editor and cooking pages that show their path, so tests can follow
/// navigation. The recipe is in no joint share unless [spaces] says so.
/// Returns the router.
Future<GoRouter> pumpHistory(
  WidgetTester tester,
  String location, {
  List<Override> overrides = const [],
  FakeRecipeSpaceRepository? spaces,
}) async {
  final router = GoRouter(
    initialLocation: location,
    routes: [
      ...ExperimentsRoutes.routes,
      for (final path in ['/editor/:recipeId', '/cook/:recipeId'])
        GoRoute(
          path: path,
          builder: (context, state) => Scaffold(body: Text(state.uri.path)),
        ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        recipeSpaceRepositoryProvider.overrideWithValue(
          spaces ?? FakeRecipeSpaceRepository(),
        ),
        ...overrides,
      ],
      child: MaterialApp.router(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}
