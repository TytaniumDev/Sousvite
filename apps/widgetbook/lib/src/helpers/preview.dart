import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// Frames a use case: centered, with page padding, and at most [maxWidth]
/// wide so row widgets look the way they do on a phone.
class const Preview({
  /// The component being shown.
  required final Widget child,

  /// The widest the component may be. Null lets it size itself.
  final double? maxWidth = phoneWidth,
  super.key,
}) extends StatelessWidget {
  /// A compact window's width, for widgets that fill their row.
  static const double phoneWidth = 360;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        child: child,
      ),
    ),
  );
}
