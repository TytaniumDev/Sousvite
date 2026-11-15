import 'package:design_system/design_system.dart';
import 'package:design_system/src/widgets/status_pill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  group(StatusPill, () {
    testWidgets('shows the icon and word in the foreground color', (
      tester,
    ) async {
      const foreground = AppColorSchemes.light;
      await tester.pumpDesignSystem(
        StatusPill(
          icon: Symbols.science_rounded,
          label: 'Experiment',
          background: foreground.tertiaryContainer,
          foreground: foreground.onTertiaryContainer,
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Symbols.science_rounded);
      expect(icon.color, foreground.onTertiaryContainer);
      expect(icon.size, StatusPill.iconSize);
      final text = tester.widget<Text>(find.text('Experiment'));
      expect(text.style?.color, foreground.onTertiaryContainer);
      final box = tester.widget<DecoratedBox>(find.byType(DecoratedBox).last);
      expect(
        (box.decoration as BoxDecoration).color,
        foreground.tertiaryContainer,
      );
    });
  });
}
