import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/library/presentation/folder_tile.dart';

import '../../../helpers/helpers.dart';
import '../../../helpers/photos.dart';

void main() {
  final photo = MemoryImage(testJpeg());

  Future<void> pumpTile(
    WidgetTester tester, {
    List<ImageProvider> images = const [],
    String? countLabel,
    VoidCallback? onTap,
  }) => tester.pumpApp(
    Scaffold(
      body: Center(
        child: SizedBox(
          width: 160,
          child: FolderTile(
            title: 'Breakfast',
            countLabel: countLabel,
            images: images,
            onTap: onTap ?? () {},
          ),
        ),
      ),
    ),
  );

  group(FolderTile, () {
    testWidgets('shows the name, count, and a folder icon with no photos', (
      tester,
    ) async {
      var taps = 0;
      await pumpTile(tester, countLabel: '3 recipes', onTap: () => taps++);

      expect(find.text('Breakfast'), findsOneWidget);
      expect(find.text('3 recipes'), findsOneWidget);
      expect(find.byIcon(Symbols.folder_rounded), findsOneWidget);
      await tester.tap(find.byType(FolderTile));
      expect(taps, 1);
    });

    for (final count in [1, 2, 3, 4, 6]) {
      testWidgets('lays out $count photos in a square collage', (tester) async {
        await pumpTile(tester, images: List.filled(count, photo));

        expect(find.byType(Image), findsNWidgets(count.clamp(1, 4)));
        expect(find.text('3 recipes'), findsNothing);
        final square = tester.getSize(find.byType(AspectRatio));
        expect(square.width, square.height);
      });
    }

    testWidgets('shows a placeholder for a photo that fails to load', (
      tester,
    ) async {
      await pumpTile(tester, images: [MemoryImage(Uint8List(0))]);
      await tester.pumpAndSettle();

      expect(find.byIcon(Symbols.restaurant_rounded), findsOneWidget);
    });

    testWidgets('pads the photo and text inside its ink, like a card', (
      tester,
    ) async {
      await pumpTile(tester, countLabel: '3 recipes');

      final ink = tester.getRect(find.byType(InkWell));
      final photo = tester.getRect(find.byType(AspectRatio));
      final count = tester.getRect(find.text('3 recipes'));
      expect(ink.width, 160);
      expect(photo.left - ink.left, FolderTile.inset);
      expect(photo.top - ink.top, FolderTile.inset);
      expect(ink.right - photo.right, FolderTile.inset);
      expect(ink.bottom - count.bottom, FolderTile.inset);
    });

    testWidgets('reads as one button', (tester) async {
      await pumpTile(tester, countLabel: '3 recipes');

      expect(
        tester.getSemantics(find.byType(FolderTile)),
        matchesSemantics(
          label: 'Breakfast\n3 recipes',
          isButton: true,
          hasTapAction: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
    });
  });
}
