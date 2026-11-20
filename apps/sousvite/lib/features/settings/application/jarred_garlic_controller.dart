import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/features/settings/application/app_settings.dart';

part 'jarred_garlic_controller.g.dart';

/// Whether garlic cloves are shown as spoons of jarred minced garlic. Off
/// until settings load. Tapping a clove amount in any recipe flips it for
/// every recipe.
@Riverpod(keepAlive: true)
class JarredGarlicController() extends _$JarredGarlicController {
  @override
  bool build() =>
      ref.watch(appSettingsProvider.select((s) => s.value?.jarredGarlic)) ??
      false;

  /// Flips between cloves and jarred garlic right away, and saves it.
  Future<void> toggle() {
    final jarred = !state;
    state = jarred;
    return updateAppSettings(
      ref,
      (settings) => settings.copyWith(jarredGarlic: jarred),
    );
  }
}
