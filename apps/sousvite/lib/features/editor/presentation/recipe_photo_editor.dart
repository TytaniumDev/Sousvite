import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/editor/application/editor_draft.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/photos/photos.dart';

/// The recipe's photo, with a button to take, choose, or remove it. A
/// picked photo is saved on the device right away and joins the draft;
/// the recipe points at it once the draft is saved.
class const RecipePhotoEditor({
  /// The recipe being edited.
  required final RecipeId recipeId,
  super.key,
}) extends ConsumerWidget {
  /// The photo's width to height, as on the recipe page.
  static const double aspectRatio = 16 / 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoRef = ref.watch(
      editorDraftProvider(recipeId)
          .select((state) => state.value?.draft.recipe.photoRef),
    );
    return Column(
      crossAxisAlignment: .stretch,
      spacing: AppSpacing.space2,
      children: [
        if (photoRef != null) _Photo(photoRef: photoRef),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: _PhotoButton(recipeId: recipeId, hasPhoto: photoRef != null),
        ),
      ],
    );
  }
}

class const _Photo({required final String photoRef}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => ClipRRect(
    borderRadius: AppRadii.borderLg,
    child: AspectRatio(
      aspectRatio: RecipePhotoEditor.aspectRatio,
      child: Image(
        image: ref.watch(recipePhotosProvider).imageFor(photoRef),
        fit: .cover,
        excludeFromSemantics: true,
        errorBuilder: (context, _, _) =>
            ColoredBox(color: context.colors.surfaceContainerHighest),
      ),
    ),
  );
}

enum _PhotoAction() {
  camera,
  library,
  remove,
}

/// "Add photo" or "Change photo", opening a menu of where to get it.
class const _PhotoButton({
  required final RecipeId recipeId,
  required final bool hasPhoto,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<_PhotoButton> createState() => _PhotoButtonState();
}

class _PhotoButtonState() extends ConsumerState<_PhotoButton> {
  var _busy = false;

  Future<void> _run(_PhotoAction action) async {
    final draft = ref.read(editorDraftProvider(widget.recipeId).notifier);
    if (action == .remove) {
      draft.setPhotoRef(null);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final failed = context.l10n.editor_photoFailed;
    setState(() => _busy = true);
    try {
      final bytes = await ref
          .read(photoPickerProvider)
          .pick(action == .camera ? .camera : .library);
      if (bytes == null) return;
      draft.setPhotoRef(await ref.read(recipePhotosProvider).save(bytes));
    } on PhotoFailure {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canTakePhoto = ref.watch(
      photoPickerProvider.select((picker) => picker.canTakePhoto),
    );
    return MenuAnchor(
      menuChildren: [
        if (canTakePhoto)
          MenuItemButton(
            leadingIcon: const Icon(Symbols.photo_camera_rounded),
            onPressed: () => _run(.camera),
            child: Text(l10n.editor_takePhoto),
          ),
        MenuItemButton(
          leadingIcon: const Icon(Symbols.photo_library_rounded),
          onPressed: () => _run(.library),
          child: Text(l10n.editor_choosePhoto),
        ),
        if (widget.hasPhoto)
          MenuItemButton(
            leadingIcon: const Icon(Symbols.delete_rounded),
            onPressed: () => _run(.remove),
            child: Text(l10n.editor_removePhoto),
          ),
      ],
      builder: (context, controller, _) => OutlinedButton.icon(
        onPressed: _busy
            ? null
            : () => controller.isOpen ? controller.close() : controller.open(),
        icon: _busy
            ? const SizedBox.square(
                dimension: AppSpacing.space4,
                child: CircularProgressIndicator(),
              )
            : const Icon(Symbols.add_a_photo_rounded),
        label: Text(
          widget.hasPhoto ? l10n.editor_changePhoto : l10n.editor_addPhoto,
        ),
      ),
    );
  }
}
