import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// One way a widget is shown in its golden file (DESIGN_SYSTEM.md §12).
typedef GoldenVariant = ({String name, ThemeData theme, double textScale});

/// Light, dark, cooking light, cooking dark, and light at 200% text.
final List<GoldenVariant> goldenVariants = [
  (name: 'light', theme: AppTheme.light(), textScale: 1),
  (name: 'dark', theme: AppTheme.dark(), textScale: 1),
  (name: 'cooking light', theme: AppTheme.cooking(.light), textScale: 1),
  (name: 'cooking dark', theme: AppTheme.cooking(.dark), textScale: 1),
  (name: '200% text', theme: AppTheme.light(), textScale: 2),
];

/// A golden test that shows each of [scenarios] in every [goldenVariants]
/// entry, one row per scenario and one column per variant.
///
/// [width] fixes the width of each cell, for widgets that fill their row.
/// Leave it null for widgets that size themselves, such as chips.
///
/// Like `testWidgets`, it registers the test and returns at once.
void designSystemGoldenTest(
  String description, {
  required String fileName,
  required Map<String, Widget> scenarios,
  double? width,
  PumpAction pumpBeforeTest = onlyPumpAndSettle,
}) => unawaited(
  goldenTest(
    description,
    fileName: fileName,
    pumpBeforeTest: pumpBeforeTest,
    builder: () => GoldenTestGroup(
      columns: goldenVariants.length,
      // Fixed columns, so widgets that fill their row never get asked for
      // their intrinsic width.
      columnWidthBuilder: width == null
          ? null
          : (_) => FixedColumnWidth(width + 2 * AppSpacing.space2),
      children: [
        for (final MapEntry(key: name, value: child) in scenarios.entries)
          for (final variant in goldenVariants)
            GoldenTestScenario(
              name: '$name, ${variant.name}',
              constraints: width == null
                  ? null
                  : BoxConstraints.tightFor(width: width),
              child: GoldenVariantFrame(variant: variant, child: child),
            ),
      ],
    ),
  ),
);

/// Shows [child] on the surface of [variant]'s theme at its text scale.
class const GoldenVariantFrame({
  /// The theme and text scale to use.
  required final GoldenVariant variant,

  /// The widget under test.
  required final Widget child,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(variant.textScale)),
    // Alchemist's app has no Material localizations, which widgets such as
    // ReorderableListView and tooltips need.
    child: Localizations(
      locale: const Locale('en'),
      delegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      child: Theme(
        data: variant.theme,
        child: Material(
          color: variant.theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space2),
            child: child,
          ),
        ),
      ),
    ),
  );
}
