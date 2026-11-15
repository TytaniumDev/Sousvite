import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/l10n/gen/app_localizations_en.dart';
import 'package:sousvite/shared/format/duration_label.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('durations read the way people say them', () {
    expect(l10n.durationLabel(const Duration(minutes: 45)), '45 min');
    expect(l10n.durationLabel(const Duration(hours: 2)), '2 h');
    expect(
      l10n.durationLabel(const Duration(minutes: 61, seconds: 1)),
      '1 h 2 min',
    );
  });
}
