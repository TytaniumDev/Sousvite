import 'package:domain/domain.dart';
import 'package:meta/meta.dart';

/// One measuring tool in a plan from `decompose`, and how many times to
/// fill it: 2 × 1 tsp.
@immutable
final class const ToolUse(
  /// The tool, such as ½ cup.
  final Amount tool,

  /// How many times to fill it. At least 1.
  final int count,
) {
  /// The amount this use measures: [tool] times [count].
  Amount get total => tool.scaled(Quantity(count));

  @override
  bool operator ==(Object other) =>
      other is ToolUse && other.tool == tool && other.count == count;

  @override
  int get hashCode => Object.hash(tool, count);

  @override
  String toString() => '$count × $tool';
}
