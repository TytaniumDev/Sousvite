import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/settings/settings.dart';

import '../fakes.dart';

void main() {
  group(UnitSystemController, () {
    test('shows amounts as written until settings load', () {
      final container = ProviderContainer.test(
        overrides: [
          appSettingsRepositoryProvider.overrideWithValue(
            FakeAppSettingsRepository(
              const AppSettings(
                theme: ThemePreference.dark,
                unitSystem: UnitSystem.metric,
              ),
            ),
          ),
        ],
      );

      expect(container.read(unitSystemControllerProvider), UnitSystem.original);
    });

    test('shows the saved choice', () async {
      final container = ProviderContainer.test(
        overrides: [
          appSettingsRepositoryProvider.overrideWithValue(
            FakeAppSettingsRepository(
              const AppSettings(unitSystem: UnitSystem.us),
            ),
          ),
        ],
      )..listen(unitSystemControllerProvider, (_, _) {});
      await container.pump();

      expect(container.read(unitSystemControllerProvider), UnitSystem.us);
    });

    test('shows a choice right away and saves it', () async {
      final repository = FakeAppSettingsRepository(
        const AppSettings(theme: ThemePreference.dark),
      );
      final container = ProviderContainer.test(
        overrides: [
          appSettingsRepositoryProvider.overrideWithValue(repository),
        ],
      )..listen(unitSystemControllerProvider, (_, _) {});

      final saving = container
          .read(unitSystemControllerProvider.notifier)
          .select(UnitSystem.metric);

      expect(container.read(unitSystemControllerProvider), UnitSystem.metric);
      await saving;
      expect(
        repository.current,
        const AppSettings(
          theme: ThemePreference.dark,
          unitSystem: UnitSystem.metric,
        ),
      );
    });
  });
}
