import 'package:design_system/design_system.dart';
import 'package:design_system/src/widgets/status_pill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../helpers/helpers.dart';

void main() {
  const badge = ProBadge(label: 'Pro');

  group(ProBadge, () {
    testWidgets('uses the primary container and a premium icon', (
      tester,
    ) async {
      await tester.pumpDesignSystem(badge);

      final pill = tester.widget<StatusPill>(find.byType(StatusPill));
      expect(pill.icon, Symbols.workspace_premium_rounded);
      expect(pill.background, AppColorSchemes.light.primaryContainer);
      expect(find.text('Pro'), findsOneWidget);
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      await tester.expectMeetsGuidelines(badge);
    });

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'pro_badge',
      scenarios: {'pro': badge},
    );
  });
}
