import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/e2e_auth.dart';
import '../helpers/e2e_cloud.dart';
import '../helpers/e2e_device.dart';
import '../helpers/pump_device.dart';
import '../helpers/recipe_pages.dart';

/// Import a recipe from a link, edit it, cook it step by step, and put its
/// ingredients on the grocery list (ENGINEERING.md §15).
Future<void> importEditCookShop(WidgetTester tester) async {
  final phone = E2eDevice('phone', cloud: E2eCloud(), user: alice);
  addTearDown(phone.dispose);
  await phone.start();
  await pumpDevice(tester, phone);

  // Import.
  await tapOn(tester, find.text('Add recipe'));
  await tapOn(tester, find.text('Import from a link'));
  await tester.enterText(
    find.widgetWithText(TextField, 'Recipe link'),
    recipePageUrl,
  );
  await tapOn(tester, find.text('Import'));
  expect(find.text('Tomato soup'), findsOneWidget);

  // Edit, then save.
  await tester.enterText(
    find.widgetWithText(TextField, 'Recipe name'),
    'Tomato basil soup',
  );
  await tapOn(tester, find.text('Save'));

  // Saving goes back to the import screen; the recipe is in the library.
  await tapOn(tester, find.byTooltip('Back'));
  await tapOn(tester, find.text('Tomato basil soup'));
  expect(find.text('crushed tomatoes'), findsOneWidget);
  // The steps show the amounts inline on the recipe page too.
  expect(
    _text(RegExp(r'Add 2\s+cups\s+crushed tomatoes and simmer')),
    findsOneWidget,
  );

  // Cook it step by step, with the amounts in each step.
  await tapOn(tester, find.text('Start cooking'));
  expect(find.text('Step 1 of 2'), findsOneWidget);
  expect(
    _text(RegExp(r'Soften 1\s+onion in 1\s+Tbsp\s+olive oil')),
    findsOneWidget,
  );
  await tapOn(tester, find.text('Next'));
  expect(find.text('Step 2 of 2'), findsOneWidget);
  expect(_text('and simmer.'), findsOneWidget);
  await tapOn(tester, find.text('Done'));

  // Shop for it.
  await tapOn(tester, find.text('Add to grocery list'));
  await tapOn(tester, find.text('Add to list'));
  expect(find.text('Added to grocery list'), findsOneWidget);
  await tapOn(tester, find.byTooltip('Back'));
  await tapOn(tester, find.text('Grocery list'));
  expect(find.textContaining('crushed tomatoes'), findsOneWidget);
  expect(find.textContaining('onion'), findsOneWidget);
}

/// Text on screen, including text with inline amounts in it. Amounts and
/// their units are joined by no-break spaces.
Finder _text(Pattern text) => find.textContaining(text, findRichText: true);
