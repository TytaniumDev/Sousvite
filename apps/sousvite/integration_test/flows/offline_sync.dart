import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/e2e_auth.dart';
import '../helpers/e2e_cloud.dart';
import '../helpers/e2e_device.dart';
import '../helpers/pump_device.dart';
import '../helpers/seed.dart';

/// A recipe written on one device shows up on the other; an edit made
/// offline reaches the other device once the phone is back online
/// (ENGINEERING.md §15).
Future<void> offlineEditSyncs(WidgetTester tester) async {
  final cloud = E2eCloud();
  final phone = E2eDevice('phone', cloud: cloud, user: alice);
  final laptop = E2eDevice('laptop', cloud: cloud, user: alice);
  addTearDown(phone.dispose);
  addTearDown(laptop.dispose);
  await phone.start();
  await laptop.start();
  await pumpDevice(tester, phone);

  // Written on the laptop, seen on the phone.
  final recipeId = await seedRecipe(laptop, 'Cinnamon toast');
  await laptop.sync();
  await phone.sync();
  await tester.pumpAndSettle();
  expect(find.text('Cinnamon toast'), findsOneWidget);

  // Edited on the phone with no connection.
  phone.online = false;
  await tapOn(tester, find.text('Cinnamon toast'));
  await tapOn(tester, find.byTooltip('More options'));
  await tapOn(tester, find.text('Edit recipe'));
  await tester.enterText(
    find.widgetWithText(TextField, 'Recipe name'),
    'Cardamom toast',
  );
  expect(find.widgetWithText(TextField, 'Cardamom toast'), findsOneWidget);
  await tapOn(tester, find.text('Save'));
  expect(await titleOn(phone, recipeId), 'Cardamom toast');
  expect(find.text('Cardamom toast'), findsWidgets);
  await phone.sync();
  await laptop.sync();
  expect(await titleOn(laptop, recipeId), 'Cinnamon toast');

  // Back online: the edit goes up and the laptop gets it.
  phone.online = true;
  await phone.sync();
  await laptop.sync();
  expect(await titleOn(laptop, recipeId), 'Cardamom toast');
}
