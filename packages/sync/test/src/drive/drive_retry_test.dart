import 'package:sync/sync.dart';
import 'package:test/test.dart';

void main() {
  group(DriveRetry, () {
    test('backs off 1, 2, 4 seconds, then gives up', () async {
      final waits = <Duration>[];
      var calls = 0;
      final retry = DriveRetry(
        maxAttempts: 4,
        wait: (duration) async => waits.add(duration),
      );

      await expectLater(
        retry<void>(() {
          calls++;
          throw const DriveRateLimited();
        }),
        throwsA(isA<DriveRateLimited>()),
      );

      expect(calls, 4);
      expect(waits, const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 4),
      ]);
    });

    test('lets other failures through at once', () async {
      var calls = 0;

      await expectLater(
        const DriveRetry()<void>(() {
          calls++;
          throw StateError('no');
        }),
        throwsStateError,
      );

      expect(calls, 1);
    });

    test('waits for real by default', () async {
      var calls = 0;
      final value = await const DriveRetry(maxAttempts: 2)(() async {
        if (calls++ == 0) throw const DriveRateLimited();
        return 'ok';
      });

      expect(value, 'ok');
    });
  });
}
