import 'dart:math' as math;

import 'package:design_system/src/tokens/spacing.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

/// A tappable surface whose ink sits around its content with even padding
/// (DESIGN_SYSTEM.md §6.5): the ink fills the surface, then the padding,
/// then [child].
///
/// The padding is the same on both sides of each axis and at least
/// [minPadding], so the highlight on hover, focus, and press never hugs
/// the content on one side. Every ripple in the app goes through this
/// widget; the `padded_ink_wells` lint flags a bare `InkWell` or
/// `InkResponse`.
///
/// A surface smaller than a 48 dp tap target takes 48 by 48 dp of layout
/// and takes taps across all of it, the way Material's buttons do, without
/// growing the ink. [tapTargetAlignment] places the ink in that box:
/// `centerStart` keeps it at the start, so it lines up with plain text
/// above and below, such as an amount at the start of its column. A screen
/// reader's bounds follow the ink, so a surface a screen reader taps on its
/// own keeps its ink at least 48 dp.
class const PaddedInkWell({
  /// Called when the surface is tapped. Null shows no ink and ignores taps.
  required final VoidCallback? onTap,

  /// The content inside the padding.
  required final Widget child,

  /// The padding on the left and on the right.
  final double horizontal = AppSpacing.space1,

  /// The padding on the top and on the bottom.
  final double vertical = AppSpacing.space1,

  /// The corners of the ink. Null for square corners, such as a row in a
  /// list, or when an ancestor such as a `Card` clips it.
  final BorderRadius? borderRadius,

  /// The shape of the ink when it isn't a rounded rectangle, such as a
  /// `CircleBorder`. Takes the place of [borderRadius].
  final ShapeBorder? customBorder,

  /// Where a surface smaller than 48 dp sits in its 48 dp tap area.
  final AlignmentGeometry tapTargetAlignment = Alignment.center,

  /// Whether to leave the tap out of the semantics tree, for a surface
  /// whose action a screen reader gets another way, such as a custom
  /// action on its row.
  final bool excludeFromSemantics = false,
  super.key,
}) extends StatelessWidget {
  this
    : assert(
        horizontal >= minPadding && vertical >= minPadding,
        'Ink keeps at least $minPadding dp around its content.',
      ),
      assert(
        borderRadius == null || customBorder == null,
        'Give the ink one shape.',
      );

  /// The least padding between the ink's edge and the content.
  static const double minPadding = AppSpacing.space1;

  /// The smallest area that takes taps.
  static const double minTapTarget = kMinInteractiveDimension;

  @override
  Widget build(BuildContext context) => _TapTarget(
    alignment: tapTargetAlignment.resolve(Directionality.maybeOf(context)),
    // This is the one place that pads the ink, so it may use InkWell.
    // ignore: sousvite_lints/padded_ink_wells
    child: InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      customBorder: customBorder,
      excludeFromSemantics: excludeFromSemantics,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: child,
      ),
    ),
  );
}

/// Lays its child out in a box at least [PaddedInkWell.minTapTarget]
/// square, placed by [alignment], and hands taps anywhere in the box to the
/// child's center, the way Material pads its buttons. The child keeps its
/// own size, so the ink doesn't grow.
class const _TapTarget({
  required final Alignment alignment,
  required super.child,
}) extends SingleChildRenderObjectWidget {
  @override
  _RenderTapTarget createRenderObject(BuildContext context) =>
      _RenderTapTarget(alignment);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderTapTarget renderObject,
  ) => renderObject.alignment = alignment;
}

class _RenderTapTarget(Alignment alignment) extends RenderShiftedBox {
  this : super(null);

  Alignment _alignment = alignment;

  /// Where the child sits in a box bigger than it.
  Alignment get alignment => _alignment;
  set alignment(Alignment value) {
    if (value == _alignment) return;
    _alignment = value;
    markNeedsLayout();
  }

  Size _grow(Size size) => Size(
    math.max(size.width, PaddedInkWell.minTapTarget),
    math.max(size.height, PaddedInkWell.minTapTarget),
  );

  @override
  double computeMinIntrinsicWidth(double height) => math.max(
    super.computeMinIntrinsicWidth(height),
    PaddedInkWell.minTapTarget,
  );

  @override
  double computeMaxIntrinsicWidth(double height) => math.max(
    super.computeMaxIntrinsicWidth(height),
    PaddedInkWell.minTapTarget,
  );

  @override
  double computeMinIntrinsicHeight(double width) => math.max(
    super.computeMinIntrinsicHeight(width),
    PaddedInkWell.minTapTarget,
  );

  @override
  double computeMaxIntrinsicHeight(double width) => math.max(
    super.computeMaxIntrinsicHeight(width),
    PaddedInkWell.minTapTarget,
  );

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) =>
      constraints.constrain(_grow(child!.getDryLayout(constraints)));

  @override
  void performLayout() {
    final child = this.child!..layout(constraints, parentUsesSize: true);
    size = constraints.constrain(_grow(child.size));
    (child.parentData! as BoxParentData).offset = alignment.alongOffset(
      size - child.size as Offset,
    );
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (super.hitTest(result, position: position)) return true;
    final child = this.child!;
    if (!size.contains(position)) return false;
    final center = child.size.center(Offset.zero);
    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(center),
      position: center,
      hitTest: (result, position) => child.hitTest(result, position: center),
    );
  }
}
