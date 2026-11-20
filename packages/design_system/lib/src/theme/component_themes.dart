import 'package:design_system/src/tokens/radii.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:material_ui/material_ui.dart';

/// Component themes that give Material widgets our shapes and surfaces
/// (DESIGN_SYSTEM.md §6.4, §9.1). Buttons keep Material's fully rounded
/// default.
///
/// Every button pads its content evenly inside its ink, at least 4 dp on
/// each side and at every text size (§6.5). Material pads the icon side of
/// `.icon` buttons less and drops the padding toward nothing at large
/// text, so these set it.
abstract final class AppComponentThemes() {
  /// The padding inside a button's ink: [horizontal] on the left and the
  /// right, and 4 dp on the top and the bottom, which only shows once the
  /// text outgrows the button's 40 dp height.
  static ButtonStyle _padded(double horizontal) => const ButtonStyle().copyWith(
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: horizontal, vertical: AppSpacing.space1),
    ),
  );

  /// Text buttons, with Material's 12 dp on both sides.
  static TextButtonThemeData textButton(ColorScheme scheme) =>
      TextButtonThemeData(style: _padded(AppSpacing.space3));

  /// Filled and tonal buttons, with Material's 24 dp on both sides.
  static FilledButtonThemeData filledButton(ColorScheme scheme) =>
      FilledButtonThemeData(style: _padded(AppSpacing.space6));

  /// Outlined buttons, with Material's 24 dp on both sides.
  static OutlinedButtonThemeData outlinedButton(ColorScheme scheme) =>
      OutlinedButtonThemeData(style: _padded(AppSpacing.space6));

  /// Elevated buttons, with Material's 24 dp on both sides.
  static ElevatedButtonThemeData elevatedButton(ColorScheme scheme) =>
      ElevatedButtonThemeData(style: _padded(AppSpacing.space6));

  /// Segmented buttons, with Material's 12 dp on both sides of a segment.
  static SegmentedButtonThemeData segmentedButton(ColorScheme scheme) =>
      SegmentedButtonThemeData(style: _padded(AppSpacing.space3));

  /// Menu items, with Material's 12 dp on both sides.
  static MenuButtonThemeData menuButton(ColorScheme scheme) =>
      MenuButtonThemeData(style: _padded(AppSpacing.space3));

  static CardThemeData card(ColorScheme scheme) => CardThemeData(
    color: scheme.surfaceContainerLow,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
  );

  static ChipThemeData chip(ColorScheme scheme) => const ChipThemeData(
    shape: RoundedRectangleBorder(borderRadius: AppRadii.borderSm),
  );

  static InputDecorationThemeData input(ColorScheme scheme) =>
      InputDecorationThemeData(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: const OutlineInputBorder(
          borderRadius: AppRadii.borderSm,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderSm,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      );

  static BottomSheetThemeData bottomSheet(ColorScheme scheme) =>
      BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        modalBackgroundColor: scheme.surfaceContainerHigh,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.xl),
          ),
        ),
      );

  static DialogThemeData dialog(ColorScheme scheme) => DialogThemeData(
    backgroundColor: scheme.surfaceContainerHigh,
    elevation: 0,
    shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderXl),
  );

  static SnackBarThemeData snackBar(ColorScheme scheme) => SnackBarThemeData(
    backgroundColor: scheme.inverseSurface,
    actionTextColor: scheme.inversePrimary,
    behavior: SnackBarBehavior.floating,
    shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderSm),
  );

  static FloatingActionButtonThemeData fab(ColorScheme scheme) =>
      const FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
      );

  static NavigationBarThemeData navigationBar(ColorScheme scheme) =>
      NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
      );

  static NavigationRailThemeData navigationRail(ColorScheme scheme) =>
      NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
      );

  static ListTileThemeData listTile(ColorScheme scheme) =>
      const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
        minTileHeight: 56,
      );
}
