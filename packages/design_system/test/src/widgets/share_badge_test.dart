import 'package:design_system/design_system.dart';
import 'package:design_system/src/widgets/status_pill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../helpers/helpers.dart';

void main() {
  const scheme = AppColorSchemes.light;

  group(ShareBadge, () {
    testWidgets('marks a joint share in sage with a group icon', (
      tester,
    ) async {
      await tester.pumpDesignSystem(
        const ShareBadge(kind: .joint, label: 'Shared'),
      );

      final pill = tester.widget<StatusPill>(find.byType(StatusPill));
      expect(pill.icon, Symbols.group_rounded);
      expect(pill.background, scheme.secondaryContainer);
      expect(find.text('Shared'), findsOneWidget);
    });

    testWidgets('marks a copy as neutral', (tester) async {
      await tester.pumpDesignSystem(
        const ShareBadge(kind: .copy, label: 'Copy'),
      );

      final pill = tester.widget<StatusPill>(find.byType(StatusPill));
      expect(pill.icon, Symbols.content_copy_rounded);
      expect(pill.background, scheme.surfaceContainerHigh);
      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      for (final kind in ShareBadgeKind.values) {
        await tester.expectMeetsGuidelines(
          ShareBadge(kind: kind, label: kind.name),
        );
      }
    });

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'share_badge',
      scenarios: {
        'joint': const ShareBadge(kind: .joint, label: 'Shared'),
        'copy': const ShareBadge(kind: .copy, label: 'Copy'),
      },
    );
  });
}
