import 'package:design_system/src/tokens/spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// How far [FadingEdges] fades each edge of a scroll view, from 0 (sharp)
/// to 1 (fully faded), and which way the scroll view runs.
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
/// Each edge fades in over the first [extent] of content scrolled past it,
/// so an edge is sharp at the very top or bottom of the list and a short
/// list that doesn't scroll has no fade at all. Only the scroll view
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

  double _amount(double scrolledPast) =>
      clampDouble(scrolledPast / widget.extent, 0, 1);

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollMetricsNotification>(
        // Sent after layout, so the fades are right before anyone scrolls
        // and whenever the content grows or shrinks.
        onNotification: (n) => _onMetrics(n.metrics, n.depth),
        child: NotificationListener<ScrollUpdateNotification>(
          onNotification: (n) => _onMetrics(n.metrics, n.depth),
          child: _FadeMask(
            fades: _fades,
            extent: widget.extent,
            child: widget.child,
          ),
        ),
      );
}

/// Paints [child] through a mask that fades it out at its edges by
/// [fades].
class const _FadeMask({
  required final ValueListenable<EdgeFades> fades,
  required final double extent,
  required super.child,
}) extends SingleChildRenderObjectWidget {
  @override
  RenderFadeMask createRenderObject(BuildContext context) =>
      RenderFadeMask(fades: fades, extent: extent);

  @override
  void updateRenderObject(BuildContext context, RenderFadeMask renderObject) {
    renderObject
      ..fades = fades
      ..extent = extent;
  }
}

/// Paints its child through a gradient mask that fades it out at the
/// edges [fades] names, and repaints whenever [fades] changes.
///
/// Public only so tests can read the fades it paints.
@visibleForTesting
class RenderFadeMask({
  /// How far each edge is faded.
  required var ValueListenable<EdgeFades> _fades,

  /// How tall (or wide) each fade is.
  required var double _extent,
}) extends RenderProxyBox {
  /// How far each edge is faded.
  ValueListenable<EdgeFades> get fades => _fades;
  set fades(ValueListenable<EdgeFades> value) {
    if (value == _fades) return;
    if (attached) {
      _fades.removeListener(markNeedsPaint);
      value.addListener(markNeedsPaint);
    }
    _fades = value;
    markNeedsPaint();
  }

  /// How tall (or wide) each fade is.
  double get extent => _extent;
  set extent(double value) {
    if (value == _extent) return;
    _extent = value;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _fades.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _fades.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  bool get alwaysNeedsCompositing => child != null;

  @override
  ShaderMaskLayer? get layer => super.layer as ShaderMaskLayer?;

  @override
  void paint(PaintingContext context, Offset offset) {
    final fades = _fades.value;
    if (child == null) return;
    if (fades.start == 0 && fades.end == 0) {
      layer = null;
      context.paintChild(child!, offset);
      return;
    }
    layer = (layer ?? ShaderMaskLayer())
      ..shader = _gradient(fades).createShader(Offset.zero & size)
      ..maskRect = offset & size
      ..blendMode = .dstIn;
    context.pushLayer(layer!, super.paint, offset);
  }

  /// Opaque in the middle, fading towards each edge by how far that edge
  /// is faded. Runs from the scroll view's start to its end.
  LinearGradient _gradient(EdgeFades fades) {
    final length = axisDirectionToAxis(fades.direction) == .vertical
        ? size.height
        : size.width;
    // Each fade takes at most half the scroll view, so they never cross.
    final stop = length == 0 ? 0.5 : clampDouble(extent / length, 0, 0.5);
    const opaque = Color(0xFF000000);
    final (begin, end) = switch (fades.direction) {
      .down => (Alignment.topCenter, Alignment.bottomCenter),
      .up => (Alignment.bottomCenter, Alignment.topCenter),
      .right => (Alignment.centerLeft, Alignment.centerRight),
      .left => (Alignment.centerRight, Alignment.centerLeft),
    };
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        opaque.withValues(alpha: 1 - fades.start),
        opaque,
        opaque,
        opaque.withValues(alpha: 1 - fades.end),
      ],
      stops: [0, stop, 1 - stop, 1],
    );
  }
}
