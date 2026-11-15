import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  group(CompactDensity, () {
    testWidgets('makes its subtree compact', (tester) async {
      late ThemeData inside;
      await tester.pumpDesignSystem(
        CompactDensity(
          child: Builder(
            builder: (context) {
              inside = Theme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(inside.visualDensity, VisualDensity.compact);
      expect(inside.listTileTheme.minTileHeight, CompactDensity.rowHeight);
      expect(inside.materialTapTargetSize, MaterialTapTargetSize.padded);
      expect(inside.colorScheme, AppColorSchemes.light);
    });

    testWidgets('shortens rows that follow the density', (tester) async {
      await tester.pumpDesignSystem(
        const CompactDensity(
          child: NutrientRow(label: 'Fat', value: 12, unit: 'g'),
        ),
      );

      expect(
        tester.getSize(find.byType(NutrientRow)).height,
        CompactDensity.rowHeight,
      );
    });
  });
}
