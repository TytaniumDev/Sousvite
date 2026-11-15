import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MacroLabels labels({String fat = 'Fat'}) => MacroLabels(
    calories: 'Calories',
    protein: 'Protein',
    carbs: 'Carbs',
    fat: fat,
    grams: 'g',
  );

  test('MacroLabels compare by value', () {
    expect(labels(), labels());
    expect(labels().hashCode, labels().hashCode);
    expect(labels(), isNot(labels(fat: 'Fats')));
  });
}
