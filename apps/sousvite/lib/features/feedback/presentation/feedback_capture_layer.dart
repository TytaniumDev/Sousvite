import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show ImageByteFormat;

import 'package:design_system/design_system.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/feedback/application/feedback_capture.dart';
import 'package:sousvite/features/feedback/application/feedback_draft.dart';
import 'package:sousvite/features/feedback/feedback_routes.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Wraps the whole app so a report can carry a screenshot of any screen.
///
/// While a capture is on, a bar floats over the app. The user goes to the
/// screen the report is about and taps Capture: the screen (without the
/// bar) is attached to the draft and the form opens again. Rebuilds only
/// when a capture starts or ends.
class const FeedbackCaptureLayer({
  /// The app's router, for the current location and to reopen the form.
  required final GoRouter router,

  /// The app.
  required final Widget child,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<FeedbackCaptureLayer> createState() =>
      _FeedbackCaptureLayerState();
}

class _FeedbackCaptureLayerState() extends ConsumerState<FeedbackCaptureLayer> {
  /// Sharp on every screen while keeping the file small enough to upload.
  static const double _maxPixelRatio = 2;

  final GlobalKey<State<StatefulWidget>> _app = GlobalKey();

  Future<void> _capture() async {
    final boundary = _app.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return;
    final pixelRatio = math.min(
      MediaQuery.devicePixelRatioOf(context),
      _maxPixelRatio,
    );
    final location = widget.router.routerDelegate.currentConfiguration.uri;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final ByteData? png;
    try {
      png = await image.toByteData(format: ImageByteFormat.png);
    } finally {
      image.dispose();
    }
    if (png == null || !mounted) return;
    ref
        .read(feedbackDraftProvider.notifier)
        .attachScreenshot(
          png.buffer.asUint8List(),
          location: location.toString(),
        );
    _reopenForm();
  }

  void _reopenForm() {
    ref.read(feedbackCaptureProvider.notifier).stop();
    unawaited(widget.router.push(FeedbackRoutes.path));
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: .expand,
    children: [
      RepaintBoundary(key: _app, child: widget.child),
      if (ref.watch(feedbackCaptureProvider))
        _CaptureBar(
          onCapture: () => unawaited(_capture()),
          onCancel: _reopenForm,
        ),
    ],
  );
}

/// Capture and Cancel, at the top of the window.
class const _CaptureBar({
  required final VoidCallback onCapture,
  required final VoidCallback onCancel,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Align(
      alignment: .topCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space2),
          child: Material(
            color: context.colors.surfaceContainerHigh,
            elevation: 3,
            shape: const StadiumBorder(),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space2),
              child: Row(
                mainAxisSize: .min,
                spacing: AppSpacing.space2,
                children: [
                  TextButton(
                    onPressed: onCancel,
                    child: Text(l10n.feedback_captureCancel),
                  ),
                  FilledButton.icon(
                    icon: const Icon(Symbols.screenshot_region_rounded),
                    label: Text(l10n.feedback_capture),
                    onPressed: onCapture,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
