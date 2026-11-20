import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/nutrition/presentation/barcode_camera.dart';

void main() {
  test('builds the mobile_scanner camera', () {
    final container = ProviderContainer.test();
    void onBarcode(String _) {}

    final camera = container.read(barcodeCameraProvider)(onBarcode);

    expect(camera, isA<MobileScannerCamera>());
    expect((camera as MobileScannerCamera).onBarcode, onBarcode);
  });
}
