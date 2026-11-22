import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:sousvite_lints/src/page_scaffolds.dart';
import 'package:test/test.dart';

void main() {
  group(PageScaffolds, () {
    late _RuleTest rule;

    setUp(() {
      rule = _RuleTest()..setUp();
    });

    tearDown(() => rule.tearDown());

    test('flags AppBar and SliverAppBar', () async {
      const code =
          '''
  $_widgets
  final a = AppBar(title: Text());
  final b = SliverAppBar();
  ''';
      await rule.assertDiagnostics(code, [
        rule.lint(rule.after(code, 'final a = '), 6),
        rule.lint(rule.after(code, 'final b = '), 12),
      ]);
    });

    test('accepts PageScaffold and other widgets', () async {
      await rule.assertNoDiagnostics('''
  $_widgets
  final a = PageScaffold(body: Text());
  final b = Text();
  ''');
    });
  });
}

/// Stand-ins for the Flutter and design_system classes the rule looks for,
/// matched by name.
const _widgets = '''
class Widget { const Widget(); }
class Text extends Widget { const Text(); }
class AppBar extends Widget {
  const AppBar({this.title});
  final Widget? title;
}
class SliverAppBar extends Widget { const SliverAppBar(); }
class PageScaffold extends Widget {
  const PageScaffold({required this.body});
  final Widget body;
}
''';

/// Runs [PageScaffolds] over snippets of code.
class _RuleTest() extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PageScaffolds();
    super.setUp();
  }

  /// Where the code right after [before] starts in [code].
  int after(String code, String before) => code.indexOf(before) + before.length;
}
