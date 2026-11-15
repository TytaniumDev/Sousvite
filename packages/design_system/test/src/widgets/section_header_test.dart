import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  group(SectionHeader, () {
    testWidgets('shows the title and step count', (tester) async {
      await tester.pumpDesignSystem(
        const SectionHeader(title: 'Prep', countLabel: '3 steps'),
      );

      expect(find.text('Prep'), findsOneWidget);
      expect(find.text('3 steps'), findsOneWidget);
      expect(find.byType(ReorderableDragStartListener), findsNothing);
    });

    testWidgets('shows a drag handle that reorders', (tester) async {
      final semantics = tester.ensureSemantics();
      final order = ['Prep', 'Cook'];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => ReorderableListView(
                buildDefaultDragHandles: false,
                onReorderItem: (from, to) =>
                    setState(() => order.insert(to, order.removeAt(from))),
                children: [
                  for (final (index, title) in order.indexed)
                    SectionHeader(
                      key: ValueKey(title),
                      title: title,
                      reorderIndex: index,
                      reorderLabel: 'Reorder $title',
                    ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel(RegExp('Reorder Prep')), findsOneWidget);
      final handle = find.byType(ReorderableDragStartListener).first;
      final gesture = await tester.startGesture(tester.getCenter(handle));
      await gesture.moveBy(const Offset(0, 120));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(order, ['Cook', 'Prep']);
      semantics.dispose();
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      await tester.expectMeetsGuidelines(
        const SectionHeader(title: 'Prep', countLabel: '3 steps'),
      );
    });

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'section_header',
      width: 320,
      scenarios: {
        'with count': const SectionHeader(title: 'Prep', countLabel: '3 steps'),
        'title only': const SectionHeader(title: 'Bake'),
        // The handle only needs a reorderable list once a drag starts.
        'reorderable': const SectionHeader(
          title: 'Prep',
          countLabel: '3 steps',
          reorderIndex: 0,
          reorderLabel: 'Reorder Prep',
        ),
      },
    );
  });
}
