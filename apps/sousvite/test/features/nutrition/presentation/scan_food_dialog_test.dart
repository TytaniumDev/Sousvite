import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/services/nutrition_api.dart';
import 'package:sousvite/features/nutrition/presentation/barcode_camera.dart';
import 'package:sousvite/features/nutrition/presentation/scan_food_dialog.dart';

import '../../../helpers/helpers.dart';
import '../fakes.dart';

typedef _F = NutritionFixtures;

void main() {
  const barcode = '0051500255162';
  final butter = _F.packaged('Creamy Peanut Butter', servingGrams: 33);
  final photo = Uri.parse('https://images.example/jif.jpg');
  final found = (food: butter, imageUrl: photo);
  late FakeNutritionApi api;
  late List<ScannedProduct?> results;

  setUp(() {
    api = FakeNutritionApi(
      const [],
      barcodes: {barcode: butter},
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

  testWidgets('closes with the product it finds, with its photo', (
    tester,
  ) async {
    await openScanner(tester);

    await scan(tester);

    expect(api.lookups, [barcode]);
    expect(results, [found]);
    expect(find.text('Scan a barcode'), findsNothing);
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

    expect(api.lookups, [barcode, barcode]);
    expect(results, [found]);
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
    await tester.pumpAndSettle();
    expect(results, [found]);
  });
}
