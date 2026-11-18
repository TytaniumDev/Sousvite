import 'dart:math' as math;

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
/// On a window narrower than [maxWidth] the insets are zero, so phones look
/// the same as without it.
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

  /// The widest a page with two panes side by side gets, such as the
  /// recipe page's ingredients and steps.
  static const double twoPaneWidth = 1200;

  /// The side insets that center a column at most [maxWidth] wide in a
  /// space [width] wide.
  static EdgeInsets insetsFor(double width, {double maxWidth = readingWidth}) =>
      EdgeInsets.symmetric(horizontal: math.max(0, (width - maxWidth) / 2));

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) =>
        builder(context, insetsFor(constraints.maxWidth, maxWidth: maxWidth)),
  );
}
