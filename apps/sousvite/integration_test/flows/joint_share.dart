import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/sharing/application/recipe_sharing.dart';

import '../helpers/e2e_auth.dart';
import '../helpers/e2e_cloud.dart';
import '../helpers/e2e_device.dart';
import '../helpers/pump_device.dart';
import '../helpers/seed.dart';

/// Alice shares a recipe jointly from the share screen, Bob joins with the
/// invite link, and each sees the other's edits (PRD 7.10).
Future<void> jointShareEdits(WidgetTester tester) async {
  final cloud = E2eCloud();
  final phone = E2eDevice('alice', cloud: cloud, user: alice);
  final tablet = E2eDevice('bob', cloud: cloud, user: bob);
  addTearDown(phone.dispose);
  addTearDown(tablet.dispose);
  await phone.start();
  await tablet.start();
  final recipeId = await seedRecipe(phone, 'Shared soup');
  await pumpDevice(tester, phone);

  // Alice makes an invite link on the share screen. The recipe is in no
  // folder yet, so it waits under Unsorted.
  await tapOn(tester, find.text('Unsorted'));
  await tapOn(tester, find.text('Shared soup'));
  await tapOn(tester, find.byTooltip('More options'));
  await tapOn(tester, find.text('Share'));
  await tapOn(tester, find.text('Create invite link'));
  final inviteId = cloud.lastInviteId!;
  expect(
    find.text('https://sousvite.web.app/invite/$inviteId'),
    findsOneWidget,
  );
  expect(find.text('Leave share'), findsOneWidget);

  // Bob opens it and joins; the recipe reaches him through the share.
  await tablet.container.read(recipeSharingProvider).accept(inviteId);
  await _syncBoth(tester, phone, tablet);
  expect(await titleOn(tablet, recipeId), 'Shared soup');

  // Bob's edit reaches Alice's screen.
  await renameRecipe(tablet, recipeId, 'Shared tomato soup');
  await _syncBoth(tester, tablet, phone);
  await tapOn(tester, find.byTooltip('Back'));
  expect(find.text('Shared tomato soup'), findsWidgets);

  // And Alice's reaches Bob.
  await renameRecipe(phone, recipeId, 'Our tomato soup');
  await _syncBoth(tester, phone, tablet);
  expect(await titleOn(tablet, recipeId), 'Our tomato soup');
}

/// Lets membership changes reach both devices' sync, then syncs [first]
/// and [second] in that order.
Future<void> _syncBoth(
  WidgetTester tester,
  E2eDevice first,
  E2eDevice second,
) async {
  await tester.pumpAndSettle();
  await first.sync();
  await second.sync();
  await tester.pumpAndSettle();
}
