import 'package:design_system/design_system.dart';
import 'package:design_system/src/theme/component_themes.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// The space between the edge of an ink and the content inside it.
typedef _Insets = ({double left, double right, double top, double bottom});

void main() {
  const add = Icon(Symbols.add_rounded);
  const label = Text('Save');

  // Every Material widget with a ripple that the app uses, plus our chip.
  final components = <String, Widget>{
    'TextButton': TextButton(onPressed: () {}, child: label),
    'TextButton.icon': TextButton.icon(
      onPressed: () {},
      icon: add,
      label: label,
    ),
    'FilledButton': FilledButton(onPressed: () {}, child: label),
    'FilledButton.icon': FilledButton.icon(
      onPressed: () {},
      icon: add,
      label: label,
    ),
    'FilledButton.tonal': FilledButton.tonal(onPressed: () {}, child: label),
    'FilledButton.tonalIcon': FilledButton.tonalIcon(
      onPressed: () {},
      icon: add,
      label: label,
    ),
    'OutlinedButton': OutlinedButton(onPressed: () {}, child: label),
    'OutlinedButton.icon': OutlinedButton.icon(
      onPressed: () {},
      icon: add,
      label: label,
    ),
    'ElevatedButton': ElevatedButton(onPressed: () {}, child: label),
    'IconButton': IconButton(onPressed: () {}, icon: add),
    'ListTile': SizedBox(
      width: 320,
      child: ListTile(
        onTap: () {},
        leading: add,
        title: label,
        trailing: const Icon(Symbols.chevron_right_rounded),
      ),
    ),
    'MenuItemButton': IntrinsicWidth(
      child: MenuItemButton(onPressed: () {}, leadingIcon: add, child: label),
    ),
    'SegmentedButton': SegmentedButton<int>(
      segments: const [
        ButtonSegment(value: 0, label: Text('US')),
        ButtonSegment(value: 1, label: Text('Metric')),
      ],
      selected: const {0},
      showSelectedIcon: false,
      onSelectionChanged: (_) {},
    ),
    'TimerChip': TimerChip(
      label: '5 min',
      duration: const Duration(minutes: 5),
      doneLabel: 'Done',
      onStart: () {},
      onStop: () {},
    ),
  };

  /// The insets of every ink in the tree around the text and icons in it.
  /// Icons are text too: an `Icon` paints its glyph with a `RichText`.
  List<_Insets> inkInsets(WidgetTester tester) => [
    for (final ink in find.byType(InkWell).evaluate())
      _insetsOf(ink.renderObject! as RenderBox),
  ];

  group(AppComponentThemes, () {
    for (final scale in [1.0, 2.0, 3.0]) {
      for (final MapEntry(key: name, value: component) in components.entries) {
        testWidgets(
          '$name pads its content evenly, at least 4 dp, at ${scale}x text',
          (tester) async {
            await tester.pumpWidget(
              MaterialApp(
                theme: AppTheme.light(),
                home: MediaQuery(
                  data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                  child: Scaffold(body: Center(child: component)),
                ),
              ),
            );

            final insets = inkInsets(tester);
            expect(insets, isNotEmpty);
            for (final inset in insets) {
              expect(inset.left, closeTo(inset.right, 0.5), reason: '$inset');
              expect(inset.top, closeTo(inset.bottom, 0.5), reason: '$inset');
              for (final side in [inset.left, inset.top]) {
                expect(
                  side,
                  greaterThanOrEqualTo(PaddedInkWell.minPadding),
                  reason: '$inset',
                );
              }
            }
          },
        );
      }
    }
  });
}

_Insets _insetsOf(RenderBox ink) {
  final origin = ink.localToGlobal(Offset.zero);
  final inkRect = origin & ink.size;
  Rect? content;
  void visit(RenderObject child) {
    if (child is RenderParagraph) {
      final rect = child.localToGlobal(Offset.zero) & child.size;
      content = content?.expandToInclude(rect) ?? rect;
      return;
    }
    child.visitChildren(visit);
  }

  ink.visitChildren(visit);
  final box = content!;
  return (
    left: box.left - inkRect.left,
    right: inkRect.right - box.right,
    top: box.top - inkRect.top,
    bottom: inkRect.bottom - box.bottom,
  );
}
