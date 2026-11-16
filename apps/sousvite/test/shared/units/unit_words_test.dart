import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/l10n/gen/app_localizations_en.dart';
import 'package:sousvite/shared/units/unit_words.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('amountWord', () {
    test('uses the unit word when there is a unit', () {
      expect(l10n.amountWord(Unit.cup, 'clove', Quantity(2)), 'cups');
    });

    test('falls back to the count word, plural after more than one', () {
      expect(l10n.amountWord(null, 'clove', Quantity(1)), 'clove');
      expect(l10n.amountWord(null, 'clove', Quantity(1, 2)), 'clove');
      expect(l10n.amountWord(null, 'clove', Quantity(3)), 'cloves');
      expect(l10n.amountWord(null, 'bunch', Quantity(2)), 'bunches');
    });

    test('is null with neither', () {
      expect(l10n.amountWord(null, null, Quantity(2)), isNull);
    });
  });
}
