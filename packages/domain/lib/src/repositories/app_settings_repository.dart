// An interface has no code to run; only its empty primary constructor
// would show up, as an uncovered line.
// coverage:ignore-file

import 'package:domain/src/entities/app_settings.dart';

/// The app-wide settings (PRD 7.5, 7.6).
abstract interface class AppSettingsRepository() {
  /// The current settings. Emits the defaults until something is saved.
  Stream<AppSettings> watchSettings();

  Future<void> saveSettings(AppSettings settings);
}
