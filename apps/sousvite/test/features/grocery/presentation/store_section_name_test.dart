import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/grocery/presentation/store_section_name.dart';
import 'package:sousvite/l10n/gen/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('names every store section', () {
    final names = {
      for (final section in StoreSection.values)
        l10n.storeSectionName(section.name),
    };
    expect(names, hasLength(StoreSection.values.length));
    expect(l10n.storeSectionName(StoreSection.other.name), 'Other');
  });

  test('shows a section the user named as typed, and null as Other', () {
    expect(l10n.storeSectionName('Snacks'), 'Snacks');
    expect(l10n.storeSectionName(null), 'Other');
  });
}
