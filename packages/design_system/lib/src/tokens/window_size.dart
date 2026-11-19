import 'package:design_system/src/tokens/spacing.dart';
import 'package:flutter/widgets.dart';

/// Material's window size classes (DESIGN_SYSTEM.md §6.3), applied the same
/// way on phones, tablets, and web.
///
/// Use them for decisions about the whole window, such as the navigation
/// bar or rail. Decide panes from the space a widget gets instead, with
/// `PaneLayout`, so a screen works in any part of the window.
enum WindowSizeClass() {
  /// Under 600 dp: phones in portrait. Bottom navigation bar.
  compact,

  /// 600 to 839 dp: small tablets and foldables. Navigation rail.
  medium,

  /// 840 to 1199 dp: tablets in landscape, small browser windows. Room for
  /// two panes.
  expanded,

  /// 1200 to 1599 dp: large tablets and laptops. The rail shows labels.
  large,

  /// 1600 dp and up: desktop browser windows.
  extraLarge;

  /// Width where [medium] starts.
  static const double mediumMinWidth = 600;

  /// Width where [expanded] starts.
  static const double expandedMinWidth = 840;

  /// Width where [large] starts.
  static const double largeMinWidth = 1200;

  /// Width where [extraLarge] starts.
  static const double extraLargeMinWidth = 1600;

  /// The space between two panes.
  static const double paneSpacer = AppSpacing.space6;

  /// The size class for a window [width] in dp.
  static WindowSizeClass fromWidth(double width) {
    if (width >= extraLargeMinWidth) return extraLarge;
    if (width >= largeMinWidth) return large;
    if (width >= expandedMinWidth) return expanded;
    if (width >= mediumMinWidth) return medium;
    return compact;
  }

  /// The size class of the window around [context]. Rebuilds the caller only
  /// when the window size changes.
  static WindowSizeClass of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  /// The least space between the window's edge and the content: 16 dp on
  /// compact windows, 24 dp on wider ones.
  double get margin => this == compact ? AppSpacing.space4 : AppSpacing.space6;

  /// Whether this class is [other] or wider: `sizeClass.isAtLeast(.large)`.
  bool isAtLeast(WindowSizeClass other) => index >= other.index;
}
