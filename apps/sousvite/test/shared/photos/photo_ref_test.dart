import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/shared/photos/photo_ref.dart';

void main() {
  group('PhotoRef.parse', () {
    test('reads web addresses as remote photos', () {
      expect(
        PhotoRef.parse('https://a.com/p.jpg'),
        isA<RemotePhoto>().having(
          (p) => p.url,
          'url',
          Uri.parse('https://a.com/p.jpg'),
        ),
      );
      expect(PhotoRef.parse('http://a.com/p.jpg'), isA<RemotePhoto>());
    });

    test('reads anything else as a stored photo id', () {
      expect(
        PhotoRef.parse('5b7c-photo'),
        isA<StoredPhoto>().having((p) => p.id, 'id', '5b7c-photo'),
      );
      expect(PhotoRef.parse('file:///etc/passwd'), isA<StoredPhoto>());
    });
  });
}
