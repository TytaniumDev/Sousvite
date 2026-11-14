import 'package:domain/src/entities/user_recipe_prefs.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

/// The Light / Dark / System choice (DESIGN_SYSTEM.md §3).
enum ThemePreference() {
  /// Follow the device.
  system,

  /// Always light.
  light,

  /// Always dark.
  dark,
}

/// Settings that apply to the whole app (PRD 7.5, 7.6). Per-recipe choices
/// live in [UserRecipePrefs].
@freezed
abstract class AppSettings with _$AppSettings {
  const factory({
    @Default(ThemePreference.system) ThemePreference theme,

    /// How amounts are shown in recipes that have no choice of their own.
    @Default(UnitSystem.original) UnitSystem unitSystem,
  }) = _AppSettings;
}
