import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

/// Flags a scroll view in `lib/` that isn't the `child` of a `FadingEdges`,
/// so every list fades at its edges instead of ending in a hard line
/// (DESIGN_SYSTEM.md §10).
///
/// Scroll views are `ScrollView` subclasses (`ListView`, `GridView`,
/// `CustomScrollView`), `SingleChildScrollView`, and `ReorderableListView`.
/// A scroll view with `NeverScrollableScrollPhysics` never scrolls, so it
/// has nothing to fade and is left alone. Pagers such as `PageView` are not
/// scroll views here: a page fills its viewport.
class FadeScrollViews() extends AnalysisRule {
  /// Creates the rule.
  this
    : super(
        name: code.lowerCaseName,
        description: 'Wrap scroll views in FadingEdges.',
      );

  /// The diagnostic this rule reports.
  static const code = LintCode(
    'fade_scroll_views',
    'Scroll views fade at their edges.',
    correctionMessage:
        'Pass this scroll view as the child of a FadingEdges from '
        'design_system.',
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
  static const _scrollViews = {
    'ScrollView',
    'SingleChildScrollView',
    'ReorderableListView',
  };

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final type = node.staticType;
    if (type is! InterfaceType || !_isScrollView(type)) return;
    if (_neverScrolls(node) || _isFaded(node)) return;
    rule.reportAtNode(node.constructorName);
  }

  static bool _isScrollView(InterfaceType type) => [
    type,
    ...type.allSupertypes,
  ].any((t) => _scrollViews.contains(t.element.name));

  static bool _neverScrolls(InstanceCreationExpression node) =>
      node.argumentList.arguments.whereType<NamedArgument>().any(
        (argument) =>
            argument.name.lexeme == 'physics' &&
            argument.argumentExpression.staticType?.element?.name ==
                'NeverScrollableScrollPhysics',
      );

  /// Whether [node] is the `child:` of a `FadingEdges(...)`.
  static bool _isFaded(InstanceCreationExpression node) {
    final argument = node.parent;
    if (argument is! NamedArgument || argument.name.lexeme != 'child') {
      return false;
    }
    final widget = argument.parent?.parent;
    return widget is InstanceCreationExpression &&
        widget.staticType?.element?.name == 'FadingEdges';
  }
}
