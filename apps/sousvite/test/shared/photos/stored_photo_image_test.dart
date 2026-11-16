import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/shared/photos/stored_photo_image.dart';

import '../../helpers/fakes/fake_photo_store.dart';
import '../../helpers/photos.dart';

void main() {
  late FakePhotoStore store;

  setUp(() => store = FakePhotoStore());

  testWidgets('draws the stored photo', (tester) async {
    store.photos['a'] = testJpeg();
    await tester.pumpWidget(
      Image(image: StoredPhotoImage(store, 'a'), width: 4, height: 3),
    );
    await tester.runAsync(() async {
      await precacheImage(
        StoredPhotoImage(store, 'a'),
        tester.element(find.byType(Image)),
      );
    });
    await tester.pump();

    final state = tester.state(find.byType(Image));
    expect((state as dynamic).mounted, isTrue);
    final raw = tester.widget<RawImage>(find.byType(RawImage));
    expect(raw.image, isNotNull);
  });

  testWidgets('fails to load a photo that is not on this device', (
    tester,
  ) async {
    await tester.pumpWidget(
      Image(
        image: StoredPhotoImage(store, 'missing'),
        errorBuilder: (_, _, _) =>
            const Text('placeholder', textDirection: .ltr),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    expect(find.text('placeholder'), findsOneWidget);
  });

  test('is equal for the same photo in the same store', () {
    final other = FakePhotoStore();
    expect(StoredPhotoImage(store, 'a'), StoredPhotoImage(store, 'a'));
    expect(
      StoredPhotoImage(store, 'a').hashCode,
      StoredPhotoImage(store, 'a').hashCode,
    );
    expect(StoredPhotoImage(store, 'a'), isNot(StoredPhotoImage(store, 'b')));
    expect(StoredPhotoImage(store, 'a'), isNot(StoredPhotoImage(other, 'a')));
    expect(StoredPhotoImage(store, 'a').toString(), 'StoredPhotoImage(a)');
  });
}
