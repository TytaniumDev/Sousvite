import 'package:design_system/design_system.dart';
import 'package:design_system/src/widgets/status_pill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../helpers/helpers.dart';

void main() {
  const badge = ExperimentBadge(label: 'Experiment');

  group(ExperimentBadge, () {
    testWidgets('uses terracotta and a flask', (tester) async {
      await tester.pumpDesignSystem(badge);

      final pill = tester.widget<StatusPill>(find.byType(StatusPill));
      expect(pill.icon, Symbols.science_rounded);
      expect(pill.background, AppColorSchemes.light.tertiaryContainer);
      expect(find.text('Experiment'), findsOneWidget);
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      await tester.expectMeetsGuidelines(badge);
    });

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'experiment_badge',
      scenarios: {'experiment': badge},
    );
  });
}
