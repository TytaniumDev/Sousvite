import 'dart:math' as math;

import 'package:design_system/src/tokens/window_size.dart';
import 'package:design_system/src/widgets/reading_column.dart';
import 'package:flutter/widgets.dart';

/// Builds a pane's scroll view with the [EdgeInsets] to pad it by.
typedef PaneBuilder = Widget Function(BuildContext context, EdgeInsets insets);

/// Which side of the main pane the side pane sits on.
enum PaneSide() {
  /// Before the main pane: the left in left-to-right languages.
  start,

  /// After the main pane: the right in left-to-right languages.
  end,
}

/// Material's supporting pane layout (DESIGN_SYSTEM.md §6.3): a flexible
/// main pane beside a fixed [sideWidth] side pane, when there's room for
/// both. Otherwise one centered column, like `ReadingColumn`.
///
/// Decides from the space it gets, not the window, so it works anywhere,
/// such as beside a navigation rail.
///
/// Each builder gets insets for its scroll view's `padding`, as with
/// `ReadingColumn`. The panes stay together in the middle of the space,
/// and each scroll view fills its pane out to the edge, so it scrolls from
/// anywhere and its scrollbar stays at the edge. Each pane scrolls on its
/// own; in a `PageScaffold`, only the main pane slides the app bar away, as
/// the side pane gets no primary scroll controller.
///
/// ```dart
/// PaneLayout(
///   sideAt: .start,
///   side: (context, insets) => ListView(padding: insets, children: [...]),
///   main: (context, insets) => ListView(padding: insets, children: [...]),
///   onePane: (context, insets) => ListView(padding: insets, children: [...]),
/// )
/// ```
class const PaneLayout({
  /// The main pane, at most [mainMaxWidth] wide, when there are two panes.
  required final PaneBuilder main,

  /// The side pane, [sideWidth] wide, when there are two panes.
  required final PaneBuilder side,

  /// Everything in one centered column, when there's no room for two panes.
  required final PaneBuilder onePane,

  /// Which side of the main pane the side pane sits on.
  final PaneSide sideAt = .end,

  /// The widest the main pane, and the one-pane column, get.
  final double mainMaxWidth = ReadingColumn.readingWidth,
  super.key,
}) extends StatelessWidget {
  /// The side pane's width, including its content's own padding.
  static const double sideWidth = 360;

  /// The least space that shows two panes: Material's expanded size class.
  static const double twoPaneMinWidth = WindowSizeClass.expandedMinWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      if (width < twoPaneMinWidth) {
        return onePane(
          context,
          ReadingColumn.insetsFor(width, maxWidth: mainMaxWidth),
        );
      }
      const spacer = WindowSizeClass.paneSpacer;
      final content = math.min(
        width - 2 * ReadingColumn.minInsetFor(width),
        sideWidth + spacer + mainMaxWidth,
      );
      final outer = (width - content) / 2;
      final sideFirst = sideAt == .start;
      final ltr = Directionality.of(context) == .ltr;
      // The outer inset goes on whichever side faces the window's edge.
      EdgeInsets outside({required bool first}) => first == ltr
          ? EdgeInsets.only(left: outer)
          : EdgeInsets.only(right: outer);
      final sidePane = SizedBox(
        width: sideWidth + outer,
        // Two panes on the page's one primary controller would scroll
        // together.
        child: PrimaryScrollController.none(
          child: Builder(
            builder: (context) => side(context, outside(first: sideFirst)),
          ),
        ),
      );
      final mainPane = Expanded(
        child: main(context, outside(first: !sideFirst)),
      );
      const gap = SizedBox(width: spacer);
      return Row(
        crossAxisAlignment: .stretch,
        children: sideFirst
            ? [sidePane, gap, mainPane]
            : [mainPane, gap, sidePane],
      );
    },
  );
}
