import 'package:material_ui/material_ui.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Asks for an item to add by hand. Returns the typed name, or null when
/// the user cancels.
Future<String?> showAddItemDialog(BuildContext context) =>
    showDialog<String>(context: context, builder: (_) => const AddItemDialog());

/// A dialog with one text field for an item's name.
class const AddItemDialog({super.key}) extends StatefulWidget {
  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState() extends State<AddItemDialog> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_name.text);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.grocery_addItem),
      content: TextField(
        controller: _name,
        autofocus: true,
        textCapitalization: .sentences,
        textInputAction: .done,
        decoration: InputDecoration(labelText: l10n.grocery_itemName),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(onPressed: _submit, child: Text(l10n.grocery_add)),
      ],
    );
  }
}
