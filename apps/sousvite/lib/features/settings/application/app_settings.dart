import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/repositories.dart';

part 'app_settings.g.dart';

/// The saved app-wide settings. Kept alive because the app root reads them.
@Riverpod(keepAlive: true)
Stream<AppSettings> appSettings(Ref ref) =>
    ref.watch(appSettingsRepositoryProvider).watchSettings();

/// Saves the result of [change] applied to the current settings.
Future<void> updateAppSettings(
  Ref ref,
  AppSettings Function(AppSettings current) change,
) async {
  final current = await ref.read(appSettingsProvider.future);
  await ref.read(appSettingsRepositoryProvider).saveSettings(change(current));
}
