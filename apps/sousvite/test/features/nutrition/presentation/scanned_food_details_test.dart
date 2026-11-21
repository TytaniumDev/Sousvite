import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/nutrition/presentation/scanned_food_details.dart';

import '../../../helpers/helpers.dart';
import '../fakes.dart';

typedef _F = NutritionFixtures;

void main() {
  final butter = _F.packaged(
    'Creamy Peanut Butter',
    servingGrams: 32,
    brand: 'Jif',
    fat: 50,
  );
  final photo = Uri.parse('https://images.example/jif.jpg');

  IngredientLine line(String text, {Quantity? quantity, Unit? unit}) =>
      IngredientLine(
        id: const IngredientLineId('l1'),
        recipeId: _F.recipeId,
        rawText: text,
        sortKey: const SortKey('a'),
        quantity: quantity,
        unit: unit,
        name: 'Creamy Peanut Butter',
      );

  Future<void> pump(
    WidgetTester tester, {
    Uri? imageUrl,
    IngredientLine? forLine,
  }) => tester.pumpApp(
    Scaffold(
      body: ScannedFoodDetails(
        product: (food: butter, imageUrl: imageUrl),
        line:
            forLine ??
            line(
              '32 g Creamy Peanut Butter',
              quantity: Quantity(32),
              unit: Unit.gram,
            ),
      ),
    ),
  );

  testWidgets('shows the photo, name, brand, source, and nutrition', (
    tester,
  ) async {
    await pump(tester, imageUrl: photo);

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
    expect(find.text('Creamy Peanut Butter'), findsOneWidget);
    expect(find.text('Jif'), findsOneWidget);
    expect(find.text('Open Food Facts'), findsOneWidget);
    expect(
      find.text('192 kcal · 0 g protein · 0 g carbs · 16 g fat'),
      findsOneWidget,
    );
  });

  testWidgets('shows an icon without a photo', (tester) async {
    await pump(tester);

    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Symbols.grocery_rounded), findsOneWidget);
  });

  testWidgets("shows an icon when the photo doesn't load", (tester) async {
    await pump(tester, imageUrl: photo);

    // Test HTTP requests fail, as a broken photo link would.
    await tester.runAsync(() async {
      final image = tester.widget<Image>(find.byType(Image));
      final done = Completer<void>();
      image.image
          .resolve(ImageConfiguration.empty)
          .addListener(
            ImageStreamListener(
              (_, _) => done.complete(),
              onError: (_, _) => done.complete(),
            ),
          );
      await done.future;
    });
    await tester.pumpAndSettle();

    expect(find.byIcon(Symbols.grocery_rounded), findsOneWidget);
  });

  testWidgets('asks for an amount it can weigh', (tester) async {
    await pump(tester, forLine: line('Creamy Peanut Butter'));

    expect(
      find.text('Type the amount in grams to see its nutrition'),
      findsOneWidget,
    );
  });

  testWidgets('leaves out a missing brand', (tester) async {
    await tester.pumpApp(
      Scaffold(
        body: ScannedFoodDetails(
          product: (food: _F.packaged('Oat Milk'), imageUrl: null),
          line: line('Oat Milk'),
        ),
      ),
    );

    expect(find.text('Oat Milk'), findsOneWidget);
    expect(find.text('Open Food Facts'), findsOneWidget);
  });
}
