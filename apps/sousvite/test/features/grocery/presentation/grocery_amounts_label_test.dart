import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/grocery/presentation/grocery_amounts_label.dart';
import 'package:sousvite/l10n/gen/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('groceryAmountsLabel', () {
    test('joins amounts with plus signs and their unit words', () {
      expect(
        groceryAmountsLabel(l10n, [
          (
            quantity: Quantity(3, 8),
            unit: Unit.cup,
            countWord: null,
            approximate: false,
          ),
          (
            quantity: Quantity(200),
            unit: Unit.gram,
            countWord: null,
            approximate: false,
          ),
          (
            quantity: Quantity(2),
            unit: null,
            countWord: 'clove',
            approximate: false,
          ),
          (
            quantity: Quantity(3),
            unit: null,
            countWord: null,
            approximate: false,
          ),
        ]),
        '⅜ cup + 200 g + 2 cloves + 3',
      );
    });

    test('is empty with no amounts', () {
      expect(groceryAmountsLabel(l10n, const []), isEmpty);
    });
  });
}
