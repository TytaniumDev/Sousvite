import 'package:domain/domain.dart';
import 'package:measuring/src/decompose/tool_use.dart';

/// The largest amount [decompose] searches, in the smallest steps the tools
/// allow (⅛ tsp for a standard set, so about 80 cups), so a huge amount
/// can't stall the app.
const _maxSearchSteps = 100000;

/// The fewest fills of the user's measuring [tools] that add up to
/// [amount], such as ¾ cup → ½ cup + ¼ cup, or 5 tsp → 1 Tbsp + 2 × 1 tsp
/// (ENGINEERING.md §13).
///
/// The total may be off from [amount] by up to [tolerance] (a fraction of
/// it). Among plans with the fewest fills, the closest wins, then the one
/// with the fewest different tools, then the one using larger tools. The
/// result lists each tool once, largest first.
///
/// Only volumes can be measured with cups and spoons. Metric volumes are
/// converted (approximately) to the US tools. Returns null when [amount] is
/// not a positive volume or no combination of [tools] comes within
/// [tolerance]. Tools that are not US cups or spoons are ignored.
List<ToolUse>? decompose(
  Amount amount, {
  required Iterable<Amount> tools,
  double tolerance = measurableTolerance,
}) {
  final teaspoons = _teaspoons(amount);
  final owned = {
    for (final tool in tools)
      if (tool.unit?.family == .usVolume && tool.quantity > Quantity.zero) tool,
  }.toList()..sort((a, b) => _inTeaspoons(b).compareTo(_inTeaspoons(a)));
  if (teaspoons == null || teaspoons <= 0 || owned.isEmpty) return null;

  // Each tool as a whole number of steps of `1/denominator` teaspoon, so
  // the search adds whole numbers.
  final denominator = owned
      .map((tool) => _inTeaspoons(tool).denominator)
      .reduce((a, b) => a ~/ a.gcd(b) * b);
  final sizes = [
    for (final tool in owned)
      (_inTeaspoons(tool) * Quantity(denominator)).numerator,
  ];
  final target = teaspoons * denominator;
  final highest = (target * (1 + tolerance)).floor();
  if (highest > _maxSearchSteps) return null;
  final lowest = (target * (1 - tolerance)).ceil().clamp(1, highest + 1);

  final fills = _fewestFills(sizes, highest);
  final fewest = [
    for (var total = lowest; total <= highest; total++) ?fills[total],
  ].fold<int?>(null, (a, b) => a == null || b < a ? b : a);
  if (fewest == null) return null;

  _Plan? best;
  for (var total = lowest; total <= highest; total++) {
    if (fills[total] != fewest) continue;
    for (final counts in _plans(sizes, total, fewest)) {
      final plan = _Plan(counts, (total - target).abs());
      if (best == null || plan.isBetterThan(best)) best = plan;
    }
  }
  return [
    for (final (index, count) in best!.counts.indexed)
      if (count > 0) ToolUse(owned[index], count),
  ];
}

/// A candidate: how many times to fill each tool, and how far its total is
/// from the amount, in search steps.
final class _Plan(final List<int> counts, final double error) {
  int get distinctTools => counts.where((count) => count > 0).length;

  /// Closer first, then fewer different tools. Plans are found larger
  /// tools first, so an equal plan found later never wins.
  bool isBetterThan(_Plan other) =>
      error < other.error ||
      (error == other.error && distinctTools < other.distinctTools);
}

/// The fewest fills of [sizes] that make each total from 0 to [highest],
/// or null where no combination does.
List<int?> _fewestFills(List<int> sizes, int highest) {
  final fills = List<int?>.filled(highest + 1, null)..[0] = 0;
  for (var total = 1; total <= highest; total++) {
    for (final size in sizes) {
      final before = size > total ? null : fills[total - size];
      final current = fills[total];
      if (before != null && (current == null || before + 1 < current)) {
        fills[total] = before + 1;
      }
    }
  }
  return fills;
}

/// Every way to make [total] from exactly [fills] fills of [sizes] (largest
/// first), as a count per size, larger tools first.
Iterable<List<int>> _plans(
  List<int> sizes,
  int total,
  int fills, [
  int from = 0,
]) sync* {
  if (from == sizes.length) {
    if (total == 0 && fills == 0) yield const [];
    return;
  }
  final size = sizes[from];
  for (
    var count = [fills, total ~/ size].reduce((a, b) => a < b ? a : b);
    count >= 0;
    count--
  ) {
    final remaining = total - count * size;
    final fillsLeft = fills - count;
    // The rest only has smaller tools, so it can't fit in fewer fills.
    if (from + 1 < sizes.length && remaining > fillsLeft * sizes[from + 1]) {
      break;
    }
    for (final rest in _plans(sizes, remaining, fillsLeft, from + 1)) {
      yield [count, ...rest];
    }
  }
}

/// [amount] in teaspoons, or null if it is not a volume.
double? _teaspoons(Amount amount) => switch (amount.unit?.family) {
  .usVolume => _inTeaspoons(amount).toDouble(),
  .metricVolume => amount.approximateValueIn(.teaspoon),
  _ => null,
};

/// A US volume [amount] in teaspoons, exactly.
Quantity _inTeaspoons(Amount amount) =>
    amount.quantity * Quantity(amount.unit!.baseUnits);
