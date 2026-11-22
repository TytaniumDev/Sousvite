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
/// [captureAndOpen] screenshots the screen showing now and opens the form,
/// for the feedback button in every app bar. While a capture started from
/// the form is on, a bar floats over the app instead: the user goes to the
/// screen the report is about and taps Capture. Either way the screen
/// (without the bar) is attached to the draft. Rebuilds only when a capture
/// starts or ends.
class const FeedbackCaptureLayer({
  /// The app's router, for the current location and to reopen the form.
  required final GoRouter router,

  /// The app.
  required final Widget child,
  super.key,
}) extends ConsumerStatefulWidget {
  /// Attaches a screenshot of the screen showing now to the draft and opens
  /// the form. Opens the form without one when there is no layer above
  /// [context].
  static Future<void> captureAndOpen(BuildContext context) async {
    final scope = context.getInheritedWidgetOfExactType<_CaptureScope>();
    if (scope == null) {
      await context.push(FeedbackRoutes.path);
      return;
    }
    await scope.captureAndOpen();
  }

  @override
  ConsumerState<FeedbackCaptureLayer> createState() =>
      _FeedbackCaptureLayerState();
}

class _FeedbackCaptureLayerState() extends ConsumerState<FeedbackCaptureLayer> {
  /// Sharp on every screen while keeping the file small enough to upload.
  static const double _maxPixelRatio = 2;

  final GlobalKey<State<StatefulWidget>> _app = GlobalKey();

  /// Attaches a screenshot of the app to the draft, then opens the form.
  Future<void> _capture() async {
    final png = await _screenshot();
    if (!mounted) return;
    if (png != null) {
      ref
          .read(feedbackDraftProvider.notifier)
          .attachScreenshot(
            png,
            location: widget.router.routerDelegate.currentConfiguration.uri
                .toString(),
          );
    }
    _reopenForm();
  }

  /// The app as a PNG, or null if it can't be drawn.
  Future<Uint8List?> _screenshot() async {
    final boundary = _app.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return null;
    final pixelRatio = math.min(
      MediaQuery.devicePixelRatioOf(context),
      _maxPixelRatio,
    );
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final ByteData? png;
    try {
      png = await image.toByteData(format: ImageByteFormat.png);
    } finally {
      image.dispose();
    }
    return png?.buffer.asUint8List();
  }

  void _reopenForm() {
    ref.read(feedbackCaptureProvider.notifier).stop();
    unawaited(widget.router.push(FeedbackRoutes.path));
  }

  @override
  Widget build(BuildContext context) => _CaptureScope(
    captureAndOpen: _capture,
    child: Stack(
      fit: .expand,
      children: [
        RepaintBoundary(key: _app, child: widget.child),
        if (ref.watch(feedbackCaptureProvider))
          _CaptureBar(
            onCapture: () => unawaited(_capture()),
            onCancel: _reopenForm,
          ),
      ],
    ),
  );
}

/// Lets [FeedbackCaptureLayer.captureAndOpen] reach the layer from any
/// screen.
class const _CaptureScope({
  required final Future<void> Function() captureAndOpen,
  required super.child,
}) extends InheritedWidget {
  // The callback is the layer's own method, which never changes.
  @override
  bool updateShouldNotify(_CaptureScope oldWidget) => false;
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
