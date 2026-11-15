import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite_widgetbook/src/helpers/quantity_knob.dart';
import 'package:units/units.dart';

void main() {
  group('sampleQuantities', () {
    test('are distinct, so the dropdown can tell them apart', () {
      expect(sampleQuantities.toSet(), hasLength(sampleQuantities.length));
    });

    test('include fractions without a glyph', () {
      expect(sampleQuantities.map((q) => q.format()), contains('5/16'));
    });
  });
}
