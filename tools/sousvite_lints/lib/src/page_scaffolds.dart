import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

/// Flags an `AppBar` or `SliverAppBar` made in `lib/`, so every page goes
/// through design_system's `PageScaffold`. Its app bar slides away on
/// scroll down, snaps back on scroll up, and carries the actions the app
/// shows on every page, such as Send feedback (DESIGN_SYSTEM.md §10.12).
class PageScaffolds() extends AnalysisRule {
  /// Creates the rule.
  this
    : super(
        name: code.lowerCaseName,
        description: 'Build pages with PageScaffold, not a bare app bar.',
      );

  /// The diagnostic this rule reports.
  static const code = LintCode(
    'page_scaffolds',
    'Pages get their app bar from PageScaffold.',
    correctionMessage:
        'Use PageScaffold from design_system and pass it the title, leading, '
        'and actions.',
    severity: .WARNING,
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!context.isInLibDir) return;
    registry.addInstanceCreationExpression(this, _Visitor(this));
  }
}

class _Visitor(final AnalysisRule rule) extends SimpleAstVisitor<void> {
  static const _appBars = {'AppBar', 'SliverAppBar'};

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final type = node.staticType;
    if (type is! InterfaceType) return;
    final isAppBar = [
      type,
      ...type.allSupertypes,
    ].any((t) => _appBars.contains(t.element.name));
    if (isAppBar) rule.reportAtNode(node.constructorName);
  }
}
