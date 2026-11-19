import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:sousvite_lints/src/fade_scroll_views.dart';
import 'package:test/test.dart';

void main() {
  group(FadeScrollViews, () {
    late _RuleTest rule;

    setUp(() {
      rule = _RuleTest()..setUp();
    });

    tearDown(() => rule.tearDown());

    test('flags a scroll view that is not faded', () async {
      const code =
          '''
  $_widgets
  final a = ListView();
  final b = CustomScrollView();
  final c = SingleChildScrollView();
  final d = ReorderableListView();
  final e = ListView.builder();
  ''';
      await rule.assertDiagnostics(code, [
        rule.lint(rule.after(code, 'final a = '), 8),
        rule.lint(rule.after(code, 'final b = '), 16),
        rule.lint(rule.after(code, 'final c = '), 21),
        rule.lint(rule.after(code, 'final d = '), 19),
        rule.lint(rule.after(code, 'final e = '), 16),
      ]);
    });

    test('accepts a scroll view that is the child of FadingEdges', () async {
      await rule.assertNoDiagnostics('''
  $_widgets
  final a = FadingEdges(child: ListView());
  final b = FadingEdges(child: CustomScrollView());
  ''');
    });

    test(
      'flags a scroll view with something between it and FadingEdges',
      () async {
        const code =
            '''
  $_widgets
  final a = FadingEdges(child: Center(child: ListView()));
  ''';
        await rule.assertDiagnostics(code, [
          rule.lint(rule.after(code, 'Center(child: '), 8),
        ]);
      },
    );

    test('accepts a scroll view that never scrolls', () async {
      await rule.assertNoDiagnostics('''
  $_widgets
  final a = ListView(physics: NeverScrollableScrollPhysics());
  ''');
    });

    test('flags a scroll view with physics that scroll', () async {
      const code =
          '''
  $_widgets
  final a = ListView(physics: ScrollPhysics());
  ''';
      await rule.assertDiagnostics(code, [
        rule.lint(rule.after(code, 'final a = '), 8),
      ]);
    });

    test('ignores pagers and other widgets', () async {
      await rule.assertNoDiagnostics('''
  $_widgets
  final a = PageView();
  final b = Center(child: PageView());
  ''');
    });
  });
}

/// Stand-ins for the Flutter and design_system classes the rule looks for,
/// matched by name.
const _widgets = '''
class Widget { const Widget(); }
class ScrollPhysics { const ScrollPhysics(); }
class NeverScrollableScrollPhysics extends ScrollPhysics {
  const NeverScrollableScrollPhysics();
}
abstract class ScrollView extends Widget {
  const ScrollView({this.physics});
  final ScrollPhysics? physics;
}
class ListView extends ScrollView {
  const ListView({super.physics});
  const ListView.builder({super.physics});
}
class CustomScrollView extends ScrollView { const CustomScrollView(); }
class SingleChildScrollView extends Widget {
  const SingleChildScrollView();
}
class ReorderableListView extends Widget { const ReorderableListView(); }
class PageView extends Widget { const PageView(); }
class FadingEdges extends Widget {
  const FadingEdges({required this.child});
  final Widget child;
}
class Center extends Widget {
  const Center({required this.child});
  final Widget child;
}
''';

/// Runs [FadeScrollViews] over snippets of code.
class _RuleTest() extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = FadeScrollViews();
    super.setUp();
  }

  /// Where the code right after [before] starts in [code].
  int after(String code, String before) => code.indexOf(before) + before.length;
}
