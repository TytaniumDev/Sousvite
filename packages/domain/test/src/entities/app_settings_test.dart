import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group(AppSettings, () {
    test('follows the system and shows amounts as written by default', () {
      const settings = AppSettings();

      expect(settings.theme, ThemePreference.system);
      expect(settings.unitSystem, UnitSystem.original);
    });

    test('has value equality', () {
      const dark = AppSettings(theme: ThemePreference.dark);

      expect(dark, const AppSettings(theme: ThemePreference.dark));
      expect(dark, isNot(const AppSettings()));
      expect(dark.copyWith(theme: ThemePreference.system), const AppSettings());
    });
  });
}
