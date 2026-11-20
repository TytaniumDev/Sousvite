import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/services/nutrition_api.dart';
import 'package:sousvite/features/nutrition/application/nutrition_providers.dart';
import 'package:sousvite/features/nutrition/presentation/barcode_camera.dart';
import 'package:sousvite/features/nutrition/presentation/scanned_product_preview.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/widgets/delayed_progress_indicator.dart';

/// Scans a packaged food's barcode with the camera, looks the food up
/// online, and shows what it found so the user can check it (PRD 7.3).
/// Returns the food once the user adds it, or null if they close the
/// scanner first.
Future<OnlineFood?> showScanFoodDialog(BuildContext context) =>
    showDialog<OnlineFood>(
      context: context,
      builder: (_) => const _ScanFoodDialog(),
    );

class const _ScanFoodDialog() extends StatefulWidget {
  @override
  State<_ScanFoodDialog> createState() => _ScanFoodDialogState();
}

class _ScanFoodDialogState() extends State<_ScanFoodDialog> {
  /// The barcode being looked up, or null while the camera looks for one.
  String? _barcode;

  @override
  Widget build(BuildContext context) => Dialog.fullscreen(
    child: Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(context.l10n.nutrition_scanTitle),
      ),
      body: switch (_barcode) {
        null => _Camera(
          onBarcode: (barcode) => setState(() => _barcode = barcode),
        ),
        final barcode => _Lookup(
          key: ValueKey(barcode),
          barcode: barcode,
          onScanAgain: () => setState(() => _barcode = null),
        ),
      },
    ),
  );
}

/// The camera, with a hint underneath.
class const _Camera({required final ValueChanged<String> onBarcode})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: .stretch,
    children: [
      Expanded(child: ref.watch(barcodeCameraProvider)(onBarcode)),
      Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Text(
          context.l10n.nutrition_scanHint,
          textAlign: .center,
          style: context.textStyles.bodyLarge,
        ),
      ),
    ],
  );
}

/// Looks up [barcode] and shows the product it finds, closing the scanner
/// with its food when the user adds it.
class const _Lookup({
  required final String barcode,
  required final VoidCallback onScanAgain,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = barcodeProductProvider(barcode);
    final l10n = context.l10n;
    return switch (ref.watch(provider)) {
      AsyncData(value: final product?) => ScannedProductPreview(
        product: product,
        onAdd: () => Navigator.of(context).pop(product.food),
        onScanAgain: onScanAgain,
      ),
      AsyncData(value: null) => _Message(
        icon: Symbols.search_off_rounded,
        text: l10n.nutrition_productNotFound(barcode),
        actions: [
          FilledButton.tonal(
            onPressed: onScanAgain,
            child: Text(l10n.nutrition_scanAgain),
          ),
        ],
      ),
      AsyncError() => _Message(
        icon: Symbols.cloud_off_rounded,
        text: l10n.nutrition_lookupFailed,
        actions: [
          TextButton(
            onPressed: onScanAgain,
            child: Text(l10n.nutrition_scanAgain),
          ),
          FilledButton.tonal(
            onPressed: () => ref.invalidate(provider),
            child: Text(l10n.common_retry),
          ),
        ],
      ),
      // Still looking.
      _ => const Center(child: DelayedProgressIndicator()),
    };
  }
}

/// Why the lookup didn't find a food, and what to do next.
class const _Message({
  required final IconData icon,
  required final String text,
  required final List<Widget> actions,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.space6),
      child: Column(
        mainAxisSize: .min,
        spacing: AppSpacing.space4,
        children: [
          Icon(icon, color: context.colors.onSurfaceVariant),
          Text(text, textAlign: .center, style: context.textStyles.bodyLarge),
          Wrap(
            alignment: .center,
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: actions,
          ),
        ],
      ),
    ),
  );
}
