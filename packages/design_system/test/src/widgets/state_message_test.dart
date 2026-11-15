import 'package:design_system/design_system.dart';
import 'package:design_system/src/widgets/state_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  group(StateMessage, () {
    testWidgets('shows the icon, title, message and action', (tester) async {
      await tester.pumpDesignSystem(
        StateMessage(
          icon: Symbols.menu_book_rounded,
          iconColor: AppColorSchemes.light.onSurfaceVariant,
          title: 'No recipes yet',
          message: 'Paste a link or write your own.',
          action: const Text('Add a recipe'),
        ),
      );

      expect(find.byIcon(Symbols.menu_book_rounded), findsOneWidget);
      expect(find.text('No recipes yet'), findsOneWidget);
      expect(find.text('Paste a link or write your own.'), findsOneWidget);
      expect(find.text('Add a recipe'), findsOneWidget);
    });

    testWidgets('marks the title as a heading', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpDesignSystem(
        StateMessage(
          icon: Symbols.menu_book_rounded,
          iconColor: AppColorSchemes.light.onSurfaceVariant,
          title: 'No recipes yet',
          message: 'Paste a link or write your own.',
        ),
      );

      expect(
        tester.getSemantics(find.text('No recipes yet')),
        isSemantics(label: 'No recipes yet', isHeader: true),
      );
      handle.dispose();
    });

    testWidgets('keeps lines readable on wide screens', (tester) async {
      await tester.pumpDesignSystem(
        StateMessage(
          icon: Symbols.menu_book_rounded,
          iconColor: AppColorSchemes.light.onSurfaceVariant,
          title: 'No recipes yet',
          message: 'Paste a link or write your own.',
        ),
      );

      expect(
        tester.getSize(find.byType(Column)).width,
        lessThanOrEqualTo(StateMessage.maxWidth),
      );
    });
  });
}
