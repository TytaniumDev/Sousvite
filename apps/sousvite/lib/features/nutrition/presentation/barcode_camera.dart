import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/l10n/l10n.dart';

part 'barcode_camera.g.dart';

/// Builds a live camera view that calls `onBarcode` with each product
/// barcode it reads.
typedef BarcodeCameraBuilder = Widget Function(ValueChanged<String> onBarcode);

/// The device camera, through mobile_scanner. Widget tests override this
/// with a fake, since the camera needs a device or browser.
@Riverpod(keepAlive: true)
BarcodeCameraBuilder barcodeCamera(Ref ref) =>
    (onBarcode) => MobileScannerCamera(onBarcode: onBarcode);

// coverage:ignore-start
// Thin wrapper around the mobile_scanner plugin, which needs a camera.

/// Reads the barcodes printed on food packages (EAN and UPC) with the back
/// camera, asking for camera access the first time.
class const MobileScannerCamera({
  /// Called with each barcode read.
  required final ValueChanged<String> onBarcode,
  super.key,
}) extends StatefulWidget {
  @override
  State<MobileScannerCamera> createState() => _MobileScannerCameraState();
}

class _MobileScannerCameraState() extends State<MobileScannerCamera> {
  final _controller = MobileScannerController(
    detectionSpeed: .noDuplicates,
    formats: const [.ean13, .ean8, .upcA, .upcE],
  );

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MobileScanner(
    controller: _controller,
    onDetect: (capture) {
      final barcode = capture.barcodes
          .map((barcode) => barcode.rawValue)
          .nonNulls
          .firstOrNull;
      if (barcode != null) widget.onBarcode(barcode);
    },
    errorBuilder: (context, _) => ColoredBox(
      color: context.colors.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space6),
          child: Text(
            context.l10n.nutrition_cameraUnavailable,
            textAlign: .center,
            style: context.textStyles.bodyLarge,
          ),
        ),
      ),
    ),
  );
}

// coverage:ignore-end
