import 'package:domain/domain.dart';
import 'package:measuring/measuring.dart';
import 'package:test/test.dart';

void main() {
  group('ToolUse', () {
    final half = Amount(Quantity(1, 2), .cup);

    test('total is the tool times the count', () {
      expect(ToolUse(half, 3).total, Amount(Quantity(3, 2), .cup));
    });

    test('compares by tool and count', () {
      expect(ToolUse(half, 2), ToolUse(half, 2));
      expect(ToolUse(half, 2).hashCode, ToolUse(half, 2).hashCode);
      expect(ToolUse(half, 2), isNot(ToolUse(half, 1)));
      expect(ToolUse(half, 2), isNot(ToolUse(Amount(Quantity(1, 3), .cup), 2)));
    });

    test('has a debug form', () {
      expect(ToolUse(half, 2).toString(), '2 × 1/2 cup');
    });
  });
}
