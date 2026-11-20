import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:sousvite_lints/src/padded_ink_wells.dart';
import 'package:test/test.dart';

void main() {
  group(PaddedInkWells, () {
    late _RuleTest rule;

    setUp(() {
      rule = _RuleTest()..setUp();
    });

    tearDown(() => rule.tearDown());

    test('flags InkWell and InkResponse', () async {
      const code =
          '''
  $_widgets
  final a = InkWell(child: Text());
  final b = InkResponse(child: Text());
  ''';
      await rule.assertDiagnostics(code, [
        rule.lint(rule.after(code, 'final a = '), 7),
        rule.lint(rule.after(code, 'final b = '), 11),
      ]);
    });

    test('accepts PaddedInkWell and other widgets', () async {
      await rule.assertNoDiagnostics('''
  $_widgets
  final a = PaddedInkWell(child: Text());
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
class InkResponse extends Widget {
  const InkResponse({required this.child});
  final Widget child;
}
class InkWell extends InkResponse {
  const InkWell({required super.child});
}
class PaddedInkWell extends Widget {
  const PaddedInkWell({required this.child});
  final Widget child;
}
''';

/// Runs [PaddedInkWells] over snippets of code.
class _RuleTest() extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PaddedInkWells();
    super.setUp();
  }

  /// Where the code right after [before] starts in [code].
  int after(String code, String before) => code.indexOf(before) + before.length;
}
