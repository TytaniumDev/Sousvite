import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/app/services/nutrition_api.dart';
import 'package:sousvite/features/nutrition/nutrition.dart';
import 'package:sousvite/l10n/l10n.dart';

import '../fakes.dart';

typedef _F = NutritionFixtures;

/// An oatmeal recipe for 4: 100 g of oats matched to a USDA food, and a cup
/// of milk with no match. Per serving that is 100 kcal, 2.5 g protein,
/// 15 g carbs, and 2 g fat.
class NutritionHarness() {
  final recipes = FakeRecipeRepository();
  final foods = FakeFoodRepository();
  final prefs = FakeUserRecipePrefsRepository();
  List<OnlineFood> online = const [];

  static const oats = IngredientLineId('oats');
  static const milk = IngredientLineId('milk');

  /// Made inside each test, so its streams run in the fake-async zone.
  Future<void> seed() async {
    await recipes.saveRecipe(_F.recipe());
    await recipes.saveIngredientLine(_F.line('oats'));
    await recipes.saveIngredientLine(
      _F.line('milk', quantity: Quantity.one, unit: Unit.cup),
    );
    foods.addFood(
      _F.food('usda-oats'),
      per100g: {'208': 400, '203': 10, '205': 60, '204': 8, '606': 2},
    );
    await foods.saveMatch(_F.match('oats', 'usda-oats', 100));
  }

  /// Opens [location] with the nutrition routes, plus a home page at `/`
  /// that shows the [NutritionSummary], as the recipe page does.
  Future<void> pump(WidgetTester tester, {String location = '/'}) async {
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: NutritionSummary(recipeId: _F.recipeId)),
        ),
        ...NutritionRoutes.routes,
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recipeRepositoryProvider.overrideWithValue(recipes),
          foodRepositoryProvider.overrideWithValue(foods),
          userRecipePrefsRepositoryProvider.overrideWithValue(prefs),
          nutritionApiProvider.overrideWithValue(FakeNutritionApi(online)),
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
  }
}
