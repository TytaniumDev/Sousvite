import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/editor/editor.dart';
import 'package:sousvite/features/import/application/import_failure.dart';
import 'package:sousvite/features/import/application/recipe_url.dart';
import 'package:sousvite/features/import/application/url_import.dart';
import 'package:sousvite/features/import/presentation/import_failure_text.dart';
import 'package:sousvite/l10n/l10n.dart';

/// A field for a recipe's web address and an Import button. A recipe that
/// imports opens in the editor for review (PRD 7.2).
class const UrlImportForm({
  /// Text shared from another app. Its link fills the field and starts
  /// importing.
  final String? sharedText,

  /// The folder the imported recipe goes into, or null for none.
  final FolderId? folderId,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<UrlImportForm> createState() => _UrlImportFormState();
}

class _UrlImportFormState() extends ConsumerState<UrlImportForm> {
  final _url = TextEditingController();

  @override
  void initState() {
    super.initState();
    final shared = widget.sharedText;
    if (shared == null) return;
    _url.text = parseRecipeUrl(shared)?.toString() ?? shared.trim();
    // Providers can't change while the tree builds.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_import());
    });
  }

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  Future<void> _import() => ref
      .read(urlImportProvider.notifier)
      .import(_url.text, folderId: widget.folderId);

  @override
  Widget build(BuildContext context) {
    ref.listen(urlImportProvider, (_, next) {
      if (next case AsyncData(value: final RecipeId id)) {
        ref.read(urlImportProvider.notifier).reset();
        _url.clear();
        unawaited(context.push(EditorRoutes.location(id)));
      }
    });
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: .stretch,
      spacing: AppSpacing.space3,
      children: [
        TextField(
          controller: _url,
          keyboardType: TextInputType.url,
          autocorrect: false,
          textInputAction: .go,
          decoration: InputDecoration(
            labelText: l10n.import_urlLabel,
            hintText: l10n.import_urlHint,
            prefixIcon: const Icon(Symbols.link_rounded),
          ),
          onSubmitted: (_) => _import(),
        ),
        const _Status(),
        _ImportButton(onPressed: _import),
      ],
    );
  }
}

class const _ImportButton({required final VoidCallback onPressed})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(urlImportProvider.select((s) => s.isLoading));
    return FilledButton(
      onPressed: busy ? null : onPressed,
      child: Text(context.l10n.import_importButton),
    );
  }
}

/// Progress while importing, and why the last import failed.
class const _Status() extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(urlImportProvider);
    final l10n = context.l10n;
    return switch (state) {
      AsyncLoading() => Row(
        spacing: AppSpacing.space3,
        children: [
          const SizedBox.square(
            dimension: AppSpacing.space5,
            child: CircularProgressIndicator(),
          ),
          Text(l10n.import_importing),
        ],
      ),
      AsyncError(error: final ImportFailure failure) => _Problem(
        message: l10n.importFailure(failure),
      ),
      AsyncError() => _Problem(message: l10n.import_failed),
      _ => const SizedBox.shrink(),
    };
  }
}

/// A warning, never an error color: a failed import is easy to fix by hand
/// (DESIGN_SYSTEM.md §4.4).
class const _Problem({required final String message}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final warning = context.appColors.warning;
    return Row(
      spacing: AppSpacing.space2,
      crossAxisAlignment: .start,
      children: [
        Icon(Symbols.warning_rounded, color: warning),
        Expanded(
          child: Text(
            message,
            style: context.textStyles.bodyMedium?.copyWith(color: warning),
          ),
        ),
      ],
    );
  }
}
