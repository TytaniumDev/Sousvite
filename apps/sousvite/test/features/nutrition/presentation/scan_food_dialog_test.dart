import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/services/nutrition_api.dart';
import 'package:sousvite/features/nutrition/presentation/barcode_camera.dart';
import 'package:sousvite/features/nutrition/presentation/scan_food_dialog.dart';
import 'package:sousvite/features/nutrition/presentation/scanned_product_preview.dart';
import 'package:sousvite/shared/widgets/delayed_progress_indicator.dart';

import '../../../helpers/helpers.dart';
import '../fakes.dart';

typedef _F = NutritionFixtures;

void main() {
  const barcode = '0051500255162';
  final butter = _F.packaged(
    'Creamy Peanut Butter',
    servingGrams: 33,
    brand: 'Jif',
    fat: 50,
  );
  final photo = Uri.parse('https://images.example/jif.jpg');
  late FakeNutritionApi api;
  late List<OnlineFood?> results;

  setUp(() {
    api = FakeNutritionApi(
      const [],
      barcodes: {barcode: butter, 'milk': _F.packaged('Oat Milk')},
      photos: {barcode: photo},
    );
    results = [];
  });

  /// Opens the scanner from a button. Its camera reads [scanned] when
  /// tapped.
  Future<void> openScanner(
    WidgetTester tester, {
    String scanned = barcode,
  }) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async =>
                results.add(await showScanFoodDialog(context)),
            child: const Text('Open'),
          ),
        ),
      ),
      overrides: [
        nutritionApiProvider.overrideWithValue(api),
        barcodeCameraProvider.overrideWithValue(
          (onBarcode) => TextButton(
            onPressed: () => onBarcode(scanned),
            child: const Text('Camera'),
          ),
        ),
      ],
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  Future<void> scan(WidgetTester tester) async {
    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the camera with a hint', (tester) async {
    await openScanner(tester);

    expect(find.text('Scan a barcode'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);
    expect(
      find.text('Point the camera at the barcode on the package'),
      findsOneWidget,
    );
  });

  /// Scrolls the product until [finder] shows, since a list builds only
  /// what's near the screen.
  Future<void> expectShown(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      100,
      scrollable: find.descendant(
        of: find.byType(ScannedProductPreview),
        matching: find.byType(Scrollable),
      ),
    );
    expect(finder, findsOneWidget);
  }

  Future<void> add(WidgetTester tester) async {
    await tester.tap(find.text('Add to recipe'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the product it finds before adding it', (tester) async {
    await openScanner(tester);

    await scan(tester);

    expect(api.lookups, [barcode]);
    expect(results, isEmpty);
    expect(find.text('Creamy Peanut Butter'), findsOneWidget);
    expect(find.text('Jif'), findsOneWidget);
    expect(
      find.widgetWithText(MatchStatusChip, 'Open Food Facts'),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is NetworkImage &&
            (widget.image as NetworkImage).url == '$photo' &&
            widget.semanticLabel == 'Photo of Creamy Peanut Butter',
      ),
      findsOneWidget,
    );
    // One 33 g label serving of a food with 600 kcal and 50 g fat in 100 g.
    final summary = find.byType(MacroSummary);
    expect(tester.widget<MacroSummary>(summary).calories, closeTo(198, 1e-9));
    expect(tester.widget<MacroSummary>(summary).fat, closeTo(16.5, 1e-9));
    expect(find.text('Per serving (33 g)'), findsOneWidget);
    await expectShown(
      tester,
      find.text(
        'Adds “33 g Creamy Peanut Butter” to the ingredients. You can change '
        'the amount after.',
      ),
    );

    await add(tester);

    expect(results, [butter]);
    expect(find.text('Scan a barcode'), findsNothing);
  });

  testWidgets('shows 100 g of a product with no serving', (tester) async {
    await openScanner(tester, scanned: 'milk');

    await scan(tester);

    expect(find.text('Per 100 g'), findsOneWidget);
    expect(
      tester.widget<MacroSummary>(find.byType(MacroSummary)).calories,
      600,
    );
    await expectShown(
      tester,
      find.text(
        'Adds “Oat Milk” to the ingredients. The label has no serving in '
        'grams, so type the amount in front of it.',
      ),
    );
    // No photo, so an icon stands in.
    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Symbols.grocery_rounded), findsOneWidget);
  });

  testWidgets("stands in an icon when the photo doesn't load", (tester) async {
    await openScanner(tester);
    await scan(tester);

    // Test HTTP requests fail, as a broken photo link would.
    await tester.runAsync(() async {
      final image = tester.widget<Image>(find.byType(Image));
      final completer = Completer<void>();
      image.image
          .resolve(ImageConfiguration.empty)
          .addListener(
            ImageStreamListener(
              (_, _) => completer.complete(),
              onError: (_, _) => completer.complete(),
            ),
          );
      await completer.future;
    });
    await tester.pumpAndSettle();

    expect(find.byIcon(Symbols.grocery_rounded), findsOneWidget);
  });

  testWidgets('scans again instead of adding the product', (tester) async {
    await openScanner(tester);
    await scan(tester);

    await tester.tap(find.text('Scan again'));
    await tester.pumpAndSettle();

    expect(find.text('Camera'), findsOneWidget);
    expect(results, isEmpty);
  });

  testWidgetsAtEverySize('keeps the product in a short column', (
    tester,
    _,
  ) async {
    await openScanner(tester);
    await scan(tester);

    tester.expectInCenteredColumn(
      find.text('Add to recipe'),
      ReadingColumn.formWidth,
    );
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  });

  testWidgets('closes with nothing when closed first', (tester) async {
    await openScanner(tester);

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    expect(results, [null]);
    expect(api.lookups, isEmpty);
  });

  testWidgets('says when no product is found, and scans again', (tester) async {
    await openScanner(tester, scanned: '123');

    await scan(tester);

    expect(
      find.text(
        'No product found for barcode 123. Scan it again, or type the '
        'ingredient instead.',
      ),
      findsOneWidget,
    );
    expect(results, isEmpty);

    await tester.tap(find.text('Scan again'));
    await tester.pumpAndSettle();
    expect(find.text('Camera'), findsOneWidget);
  });

  testWidgets('says when the lookup fails, and tries again', (tester) async {
    api.lookupError = Exception('offline');
    await openScanner(tester);

    await scan(tester);

    expect(
      find.text(
        "Couldn't look up this barcode. Check your connection and try again.",
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    await add(tester);

    expect(api.lookups, [barcode, barcode]);
    expect(results, [butter]);
  });

  testWidgets('goes back to the camera after a failed lookup', (tester) async {
    api.lookupError = Exception('offline');
    await openScanner(tester);
    await scan(tester);

    await tester.tap(find.text('Scan again'));
    await tester.pumpAndSettle();

    expect(find.text('Camera'), findsOneWidget);
  });

  testWidgets('waits on the lookup with a progress indicator', (tester) async {
    await openScanner(tester);

    await tester.tap(find.text('Camera'));
    await tester.pump();

    expect(find.text('Camera'), findsNothing);
    expect(find.byType(DelayedProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(ScannedProductPreview), findsOneWidget);
  });
}
