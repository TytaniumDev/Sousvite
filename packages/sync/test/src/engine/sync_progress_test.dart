import 'package:sync/sync.dart';
import 'package:test/test.dart';

void main() {
  group(SyncProgress, () {
    const hlc = Hlc(1000, 0, 'phone');

    test('copies with replaced fields and keeps the rest', () {
      const progress = SyncProgress(pullCursor: SyncCursor('3'));

      expect(
        progress.copyWith(pushedThrough: hlc),
        const SyncProgress(pullCursor: SyncCursor('3'), pushedThrough: hlc),
      );
      expect(
        progress.copyWith(pullCursor: const SyncCursor('4')),
        const SyncProgress(pullCursor: SyncCursor('4')),
      );
    });

    test('has value equality', () {
      expect(
        const SyncProgress(pushedThrough: hlc).hashCode,
        const SyncProgress(pushedThrough: hlc).hashCode,
      );
      expect(
        const SyncProgress(pushedThrough: hlc),
        isNot(const SyncProgress()),
      );
    });
  });
}
