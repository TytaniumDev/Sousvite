import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/features/settings/application/app_settings.dart';

part 'unit_system_controller.g.dart';

/// How amounts are shown in recipes that have no choice of their own
/// (PRD 7.6). As written until settings load.
@Riverpod(keepAlive: true)
class UnitSystemController() extends _$UnitSystemController {
  @override
  UnitSystem build() =>
      ref.watch(appSettingsProvider.select((s) => s.value?.unitSystem)) ??
      .original;

  /// Shows [unitSystem] right away and saves it.
  // A setter would read oddly at call sites: `notifier.select(units)`.
  Future<void> select(UnitSystem unitSystem) {
    state = unitSystem;
    return updateAppSettings(
      ref,
      (settings) => settings.copyWith(unitSystem: unitSystem),
    );
  }
}
