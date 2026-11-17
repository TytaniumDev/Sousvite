import 'package:sync/src/drive/drive_app_folder.dart';

/// Runs Drive calls, waiting and trying again with exponential backoff
/// (1, 2, 4, ... seconds) while Drive is rate limiting (ENGINEERING.md
/// §8.2).
final class const DriveRetry({
  /// How many times a rate-limited call is tried before giving up.
  final int maxAttempts = 6,

  /// Waits between attempts. Tests pass one that returns at once.
  final Future<void> Function(Duration) wait = _wait,
}) {
  /// Runs [call], trying again after a [DriveRateLimited].
  Future<T> call<T>(Future<T> Function() call) async {
    for (var attempt = 1; ; attempt++) {
      try {
        return await call();
      } on DriveRateLimited {
        if (attempt >= maxAttempts) rethrow;
        await wait(Duration(seconds: 1 << (attempt - 1)));
      }
    }
  }

  static Future<void> _wait(Duration duration) =>
      Future<void>.delayed(duration);
}
