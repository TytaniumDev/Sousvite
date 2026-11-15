import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// A section heading on the recipe page: "Ingredients", "Steps".
class const SectionTitle(
  /// The heading, already localized.
  final String text, {
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(text, style: context.textStyles.titleLarge),
  );
}
