import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'flows/import_to_grocery.dart';
import 'flows/joint_share.dart';
import 'flows/offline_sync.dart';

/// End-to-end flows through the whole app (ENGINEERING.md §15), run on web
/// and Android in CI. Each flow starts its own devices and cloud.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('import, edit, cook, and shop for a recipe', importEditCookShop);
  testWidgets('an offline edit syncs once back online', offlineEditSyncs);
  testWidgets('a joint share carries edits both ways', jointShareEdits);
}
