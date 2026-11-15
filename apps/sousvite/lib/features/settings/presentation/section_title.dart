import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// The heading above a group of settings.
class const SectionTitle(
  /// The heading text.
  final String title, {
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(
      AppSpacing.space4,
      AppSpacing.space6,
      AppSpacing.space4,
      AppSpacing.space2,
    ),
    child: Semantics(
      header: true,
      child: Text(
        title,
        style: context.textStyles.titleSmall?.copyWith(
          color: context.colors.primary,
        ),
      ),
    ),
  );
}
