import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/features/settings/application/app_settings.dart';

part 'theme_mode_controller.g.dart';

/// The Light / Dark / System setting (DESIGN_SYSTEM.md §3), as the
/// [ThemeMode] the app root needs. Follows the system until settings load.
@Riverpod(keepAlive: true)
class ThemeModeController() extends _$ThemeModeController {
  @override
  ThemeMode build() =>
      switch (ref.watch(appSettingsProvider.select((s) => s.value?.theme))) {
        ThemePreference.light => .light,
        ThemePreference.dark => .dark,
        ThemePreference.system || null => .system,
      };

  /// Shows [mode] right away and saves it.
  // A setter would read oddly at call sites: `notifier.select(mode)`.
  Future<void> select(ThemeMode mode) {
    state = mode;
    return updateAppSettings(
      ref,
      (settings) => settings.copyWith(
        theme: switch (mode) {
          .light => ThemePreference.light,
          .dark => ThemePreference.dark,
          .system => ThemePreference.system,
        },
      ),
    );
  }
}
