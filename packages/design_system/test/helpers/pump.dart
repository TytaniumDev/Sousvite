import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

extension PumpDesignSystem on WidgetTester {
  /// Pumps [widget] centered on a page in [theme] (light by default).
  Future<void> pumpDesignSystem(Widget widget, {ThemeData? theme}) =>
      pumpWidget(
        MaterialApp(
          theme: theme ?? AppTheme.light(),
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space4),
                child: widget,
              ),
            ),
          ),
        ),
      );

  /// Checks Flutter's accessibility guidelines (DESIGN_SYSTEM.md §12) for
  /// [widget] in every scheme.
  ///
  /// Flutter's text contrast check samples the two most common colors in a
  /// text's bounds, so text with a highlight behind part of it fails even
  /// when every pair passes. Set [textContrast] to false for those, and
  /// check the pair in `contrast_test.dart` instead.
  Future<void> expectMeetsGuidelines(
    Widget widget, {
    bool textContrast = true,
  }) async {
    final handle = ensureSemantics();
    for (final theme in [
      AppTheme.light(),
      AppTheme.dark(),
      AppTheme.cooking(.light),
      AppTheme.cooking(.dark),
    ]) {
      await pumpDesignSystem(widget, theme: theme);
      await pumpAndSettle();
      await expectLater(this, meetsGuideline(androidTapTargetGuideline));
      await expectLater(this, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(this, meetsGuideline(labeledTapTargetGuideline));
      if (textContrast) {
        await expectLater(this, meetsGuideline(textContrastGuideline));
      }
    }
    handle.dispose();
  }
}
