import 'dart:math' as math;

import 'package:design_system/src/tokens/spacing.dart';
import 'package:design_system/src/tokens/window_size.dart';
import 'package:flutter/widgets.dart';

/// Keeps a page's content in a centered column, at most [maxWidth] wide
/// (DESIGN_SYSTEM.md §6.3), so text and fields never stretch across a
/// tablet or a browser window.
///
/// [builder] gets the side insets that center the column. Give them to a
/// scroll view's `padding` (or a `SliverPadding`), so the scroll view
/// itself still fills the window: it scrolls from anywhere, and its
/// scrollbar stays at the window's edge.
///
/// ```dart
/// ReadingColumn(
///   builder: (context, insets) => ListView(
///     padding: insets + const EdgeInsets.all(AppSpacing.space4),
///     children: [...],
///   ),
/// )
/// ```
///
/// The content pads itself by [contentPadding], as list tiles do, so the
/// insets only add what's left of the window margin: none on a phone, and
/// 8 dp on wider windows, for 24 dp in all.
class const ReadingColumn({
  /// Builds the content with the side [EdgeInsets] that center it.
  required final Widget Function(BuildContext context, EdgeInsets insets)
  builder,

  /// The widest the column gets.
  final double maxWidth = readingWidth,
  super.key,
}) extends StatelessWidget {
  /// The widest a column of text, fields, or list rows gets.
  static const double readingWidth = 720;

  /// The widest a short form gets, such as signing in: a few lines of text
  /// and the buttons under them.
  static const double formWidth = 400;

  /// The padding content inside a column gives itself, as a `ListTile` does.
  static const double contentPadding = AppSpacing.space4;

  /// The least inset on each side of a column [width] wide, so the content
  /// keeps the window margin for its size class.
  static double minInsetFor(double width) =>
      WindowSizeClass.fromWidth(width).margin - contentPadding;

  /// The side insets that center a column at most [maxWidth] wide in a
  /// space [width] wide.
  static EdgeInsets insetsFor(double width, {double maxWidth = readingWidth}) =>
      EdgeInsets.symmetric(
        horizontal: math.max(minInsetFor(width), (width - maxWidth) / 2),
      );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) =>
        builder(context, insetsFor(constraints.maxWidth, maxWidth: maxWidth)),
  );
}
