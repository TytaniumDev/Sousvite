import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

/// A page of 30 rows under a "Recipes" app bar with one action of its own.
Widget _page({
  bool showPageActions = true,
  List<Widget> pageActions = const [_FeedbackAction()],
}) => PageActions(
  actions: pageActions,
  child: PageScaffold(
    title: const Text('Recipes'),
    actions: const [_SearchAction()],
    showPageActions: showPageActions,
    body: ListView(
      children: [
        for (var i = 0; i < 30; i++)
          SizedBox(height: 56, child: Text('Row $i')),
      ],
    ),
  ),
);

class const _SearchAction() extends StatelessWidget {
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Search',
    icon: const Icon(Symbols.search_rounded),
    onPressed: () {},
  );
}

class const _FeedbackAction() extends StatelessWidget {
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Send feedback',
    icon: const Icon(Symbols.feedback_rounded),
    onPressed: () {},
  );
}

Future<void> _pump(WidgetTester tester, Widget page) =>
    tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: page));

void main() {
  group(PageScaffold, () {
    double appBarBottom(WidgetTester tester) =>
        tester.getBottomLeft(find.byType(AppBar)).dy;

    testWidgets("ends the page's actions with the app's", (tester) async {
      await _pump(tester, _page());

      final search = tester.getCenter(find.byType(_SearchAction));
      final feedback = tester.getCenter(find.byType(_FeedbackAction));
      expect(find.text('Recipes'), findsOneWidget);
      expect(feedback.dx, greaterThan(search.dx));
    });

    testWidgets('leaves out the app actions when asked', (tester) async {
      await _pump(tester, _page(showPageActions: false));

      expect(find.byType(_SearchAction), findsOneWidget);
      expect(find.byType(_FeedbackAction), findsNothing);
    });

    testWidgets('shows only its own actions with no PageActions above it', (
      tester,
    ) async {
      await _pump(
        tester,
        const PageScaffold(actions: [_SearchAction()], body: Text('Body')),
      );

      expect(find.byType(_SearchAction), findsOneWidget);
      expect(find.byType(_FeedbackAction), findsNothing);
    });

    testWidgets('slides the app bar away on scroll down and snaps it back '
        'on a small scroll up', (tester) async {
      await _pump(tester, _page());
      final shown = appBarBottom(tester);
      final firstRow = tester.getTopLeft(find.text('Row 0')).dy;
      expect(firstRow, shown);

      await tester.drag(find.text('Row 3'), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsNothing);

      await tester.drag(find.text('Row 10'), const Offset(0, 20));
      await tester.pumpAndSettle();

      expect(appBarBottom(tester), shown);
      // Still well down the list: the bar came back without scrolling up.
      expect(find.text('Row 0'), findsNothing);
    });

    testWidgets('keeps the app bar in place when hiding is off', (
      tester,
    ) async {
      await _pump(
        tester,
        PageActions(
          actions: const [_FeedbackAction()],
          child: PageScaffold(
            title: const Text('Step 1 of 3'),
            hideOnScroll: false,
            body: ListView(
              children: [
                for (var i = 0; i < 30; i++)
                  SizedBox(height: 56, child: Text('Row $i')),
              ],
            ),
          ),
        ),
      );
      final shown = appBarBottom(tester);

      await tester.drag(find.text('Row 3'), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(appBarBottom(tester), shown);
      expect(find.byType(_FeedbackAction), findsOneWidget);
    });

    testWidgets('keeps the status bar clear and the body below the app bar', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: const MediaQueryData(padding: EdgeInsets.only(top: 40)),
            child: _page(),
          ),
        ),
      );

      expect(tester.getTopLeft(find.text('Recipes')).dy, greaterThan(40));
      expect(tester.getTopLeft(find.text('Row 0')).dy, appBarBottom(tester));
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      // Flutter samples each filler row's whole 56 dp band for its short
      // label and misreads the pair. The app bar's on-surface text on
      // surface is checked in contrast_test.dart.
      await tester.expectMeetsGuidelines(
        SizedBox(height: 400, child: _page()),
        textContrast: false,
      );
    });

    designSystemGoldenTest(
      'renders',
      fileName: 'page_scaffold',
      width: 360,
      scenarios: {'title and actions': SizedBox(height: 240, child: _page())},
    );
  });

  group(PageActions, () {
    testWidgets('rebuilds its dependents only when the actions change', (
      tester,
    ) async {
      var builds = 0;
      // The same child each time, so it rebuilds only when notified.
      final child = Builder(
        builder: (context) {
          builds++;
          PageActions.of(context);
          return const SizedBox();
        },
      );
      Widget app(List<Widget> actions) =>
          PageActions(actions: actions, child: child);
      const actions = [_FeedbackAction()];

      await tester.pumpWidget(app(actions));
      await tester.pumpWidget(app(actions));
      expect(builds, 1);

      await tester.pumpWidget(app(const [_SearchAction()]));
      expect(builds, 2);
    });
  });
}
