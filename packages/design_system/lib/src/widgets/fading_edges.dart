import 'package:design_system/src/tokens/spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// How tall (or wide) [FadingEdges] makes the fade at each edge of a scroll
/// view, in logical pixels, and which way the scroll view runs. 0 is a
/// sharp edge.
typedef EdgeFades = ({AxisDirection direction, double start, double end});

/// Fades a scroll view's content out at an edge while more of it is
/// scrolled past that edge, so a list never ends in a hard line under an
/// app bar or above a button (DESIGN_SYSTEM.md §10).
///
/// Wrap every scroll view in it; the `fade_scroll_views` lint checks this.
///
/// ```dart
/// FadingEdges(
///   child: ListView(children: [...]),
/// )
/// ```
///
/// Each edge always fades to fully transparent, so nothing is ever cut off
/// in a visible line. The fade is as tall as the content scrolled past that
/// edge, up to [extent]: an edge is sharp at the very top or bottom of the
/// list, the fade grows over the first [extent] scrolled, and a short list
/// that doesn't scroll has no fade at all. Only the scroll view
/// directly below it counts: a horizontal list inside a vertical one gets
/// its own [FadingEdges].
///
/// Scrolling never rebuilds anything: the fade is repainted, not rebuilt.
class const FadingEdges({
  /// The scroll view to fade, such as a `ListView` or `CustomScrollView`.
  required final Widget child,

  /// How tall (or wide, for a horizontal scroll view) each fade is.
  final double extent = defaultExtent,

  /// Whether the start (top) edge fades. Turn it off when something pinned
  /// sits at that edge, such as a sticky section header, which the fade
  /// would otherwise wash out; the header gives the edge already.
  final bool fadeStart = true,
  super.key,
}) extends StatefulWidget {
  /// The height of each fade unless a scroll view asks for another.
  static const double defaultExtent = AppSpacing.space8;

  @override
  State<FadingEdges> createState() => _FadingEdgesState();
}

class _FadingEdgesState() extends State<FadingEdges> {
  final _fades = ValueNotifier<EdgeFades>((direction: .down, start: 0, end: 0));

  @override
  void dispose() {
    _fades.dispose();
    super.dispose();
  }

  bool _onMetrics(ScrollMetrics metrics, int depth) {
    if (depth == 0) {
      _fades.value = (
        direction: metrics.axisDirection,
        start: widget.fadeStart ? _amount(metrics.extentBefore) : 0,
        end: _amount(metrics.extentAfter),
      );
    }
    return false;
  }

  /// The fade is never taller than the content hidden past the edge, so
  /// whatever the edge cuts through is always fully faded.
  double _amount(double scrolledPast) =>
      clampDouble(scrolledPast, 0, widget.extent);

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollMetricsNotification>(
        // Sent after layout, so the fades are right before anyone scrolls
        // and whenever the content grows or shrinks.
        onNotification: (n) => _onMetrics(n.metrics, n.depth),
        child: NotificationListener<ScrollUpdateNotification>(
          onNotification: (n) => _onMetrics(n.metrics, n.depth),
          child: _FadeMask(fades: _fades, child: widget.child),
        ),
      );
}

/// Paints [child] through a mask that fades it out at its edges by
/// [fades].
class const _FadeMask({
  /// The state's notifier, the same one for this widget's whole life.
  required final ValueListenable<EdgeFades> fades,
  required super.child,
}) extends SingleChildRenderObjectWidget {
  @override
  RenderFadeMask createRenderObject(BuildContext context) =>
      RenderFadeMask(fades);
}

/// Paints its child through a gradient mask that fades it out at the
/// edges [fades] names, and repaints whenever [fades] changes.
///
/// Public only so tests can read the fades it paints.
@visibleForTesting
class RenderFadeMask(
  /// How tall each edge's fade is.
  final ValueListenable<EdgeFades> fades,
) extends RenderProxyBox {
  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    fades.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    fades.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  bool get alwaysNeedsCompositing => child != null;

  @override
  ShaderMaskLayer? get layer => super.layer as ShaderMaskLayer?;

  @override
  void paint(PaintingContext context, Offset offset) {
    final value = fades.value;
    if (child == null) return;
    if (value.start == 0 && value.end == 0) {
      layer = null;
      context.paintChild(child!, offset);
      return;
    }
    layer = (layer ?? ShaderMaskLayer())
      ..shader = _gradient(value).createShader(Offset.zero & size)
      ..maskRect = offset & size
      ..blendMode = .dstIn;
    context.pushLayer(layer!, super.paint, offset);
  }

  /// Opaque in the middle and fully transparent at each faded edge, over
  /// that edge's fade. Runs from the scroll view's start to its end.
  LinearGradient _gradient(EdgeFades value) {
    final length = axisDirectionToAxis(value.direction) == .vertical
        ? size.height
        : size.width;
    // Each fade takes at most half the scroll view, so they never cross.
    double stop(double fade) =>
        length == 0 ? 0.5 : clampDouble(fade / length, 0, 0.5);
    const opaque = Color(0xFF000000);
    const clear = Color(0x00000000);
    final (begin, end) = switch (value.direction) {
      .down => (Alignment.topCenter, Alignment.bottomCenter),
      .up => (Alignment.bottomCenter, Alignment.topCenter),
      .right => (Alignment.centerLeft, Alignment.centerRight),
      .left => (Alignment.centerRight, Alignment.centerLeft),
    };
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        if (value.start > 0) clear else opaque,
        opaque,
        opaque,
        if (value.end > 0) clear else opaque,
      ],
      stops: [0, stop(value.start), 1 - stop(value.end), 1],
    );
  }
}
