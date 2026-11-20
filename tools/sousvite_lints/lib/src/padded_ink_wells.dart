import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

/// Flags an `InkWell` or `InkResponse` made in `lib/`, so every ripple goes
/// through design_system's `PaddedInkWell`, which keeps at least 4 dp of
/// even padding between the ink and its content (DESIGN_SYSTEM.md §6.5).
///
/// Material's own buttons, list tiles, and chips are left alone: the theme
/// pads them, and a test in design_system checks it.
class PaddedInkWells() extends AnalysisRule {
  /// Creates the rule.
  this
    : super(
        name: code.lowerCaseName,
        description: 'Use PaddedInkWell instead of a bare ink widget.',
      );

  /// The diagnostic this rule reports.
  static const code = LintCode(
    'padded_ink_wells',
    'Ripples pad their content evenly.',
    correctionMessage:
        'Use PaddedInkWell from design_system, which pads the content inside '
        'the ink.',
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
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final type = node.staticType;
    if (type is! InterfaceType) return;
    final isInk = [
      type,
      ...type.allSupertypes,
    ].any((t) => t.element.name == 'InkResponse');
    if (isInk) rule.reportAtNode(node.constructorName);
  }
}
