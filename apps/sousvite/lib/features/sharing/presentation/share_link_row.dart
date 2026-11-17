import 'package:design_system/design_system.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/l10n/l10n.dart';

/// A link someone can send, with a button that copies it.
class const ShareLinkRow({required final Uri link, super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: SelectableText(
            link.toString(),
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.space2),
        FilledButton.tonalIcon(
          icon: const Icon(Symbols.content_copy_rounded),
          label: Text(l10n.sharing_copyLink),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: link.toString()));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(l10n.sharing_linkCopied)));
          },
        ),
      ],
    );
  }
}
