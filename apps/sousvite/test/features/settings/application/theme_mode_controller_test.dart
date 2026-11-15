import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/settings/settings.dart';

import '../fakes.dart';

void main() {
  group(ThemeModeController, () {
    test('follows the system until settings load', () {
      final container = ProviderContainer.test();

      expect(container.read(themeModeControllerProvider), ThemeMode.system);
    });

    for (final (preference, mode) in [
      (ThemePreference.system, ThemeMode.system),
      (ThemePreference.light, ThemeMode.light),
      (ThemePreference.dark, ThemeMode.dark),
    ]) {
      test('shows the saved $preference as $mode', () async {
        final container = ProviderContainer.test(
          overrides: [
            appSettingsRepositoryProvider.overrideWithValue(
              FakeAppSettingsRepository(AppSettings(theme: preference)),
            ),
          ],
        )..listen(themeModeControllerProvider, (_, _) {});
        await container.pump();

        expect(container.read(themeModeControllerProvider), mode);
      });
    }

    test('shows a choice right away and saves it', () async {
      final repository = FakeAppSettingsRepository(
        const AppSettings(unitSystem: UnitSystem.metric),
      );
      final container = ProviderContainer.test(
        overrides: [
          appSettingsRepositoryProvider.overrideWithValue(repository),
        ],
      )..listen(themeModeControllerProvider, (_, _) {});

      final saving = container
          .read(themeModeControllerProvider.notifier)
          .select(ThemeMode.dark);

      expect(container.read(themeModeControllerProvider), ThemeMode.dark);
      await saving;
      expect(
        repository.current,
        const AppSettings(
          theme: ThemePreference.dark,
          unitSystem: UnitSystem.metric,
        ),
      );

      await container
          .read(themeModeControllerProvider.notifier)
          .select(ThemeMode.light);
      await container
          .read(themeModeControllerProvider.notifier)
          .select(ThemeMode.system);
      expect(repository.current.theme, ThemePreference.system);
    });
  });
}
