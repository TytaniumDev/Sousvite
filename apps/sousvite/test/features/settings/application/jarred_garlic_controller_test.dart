import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/settings/settings.dart';

import '../fakes.dart';

void main() {
  group(JarredGarlicController, () {
    ProviderContainer containerWith(FakeAppSettingsRepository repository) =>
        ProviderContainer.test(
          overrides: [
            appSettingsRepositoryProvider.overrideWithValue(repository),
          ],
        )..listen(jarredGarlicControllerProvider, (_, _) {});

    test('shows cloves until settings load', () {
      final container = containerWith(
        FakeAppSettingsRepository(const AppSettings(jarredGarlic: true)),
      );

      expect(container.read(jarredGarlicControllerProvider), isFalse);
    });

    test('shows the saved choice', () async {
      final container = containerWith(
        FakeAppSettingsRepository(const AppSettings(jarredGarlic: true)),
      );
      await container.pump();

      expect(container.read(jarredGarlicControllerProvider), isTrue);
    });

    test('flips right away and saves it, keeping other settings', () async {
      final repository = FakeAppSettingsRepository(
        const AppSettings(unitSystem: UnitSystem.us),
      );
      final container = containerWith(repository);
      await container.pump();
      final notifier = container.read(jarredGarlicControllerProvider.notifier);

      final saving = notifier.toggle();
      expect(container.read(jarredGarlicControllerProvider), isTrue);
      await saving;
      expect(
        repository.current,
        const AppSettings(unitSystem: UnitSystem.us, jarredGarlic: true),
      );

      await notifier.toggle();
      expect(container.read(jarredGarlicControllerProvider), isFalse);
      expect(repository.current.jarredGarlic, isFalse);
    });
  });
}
