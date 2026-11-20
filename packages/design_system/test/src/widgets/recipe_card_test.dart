import 'dart:typed_data';

import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

/// A 1×1 transparent PNG.
final _pixel = MemoryImage(
  Uint8List.fromList(const [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ]),
);

void main() {
  RecipeCard card({
    String title = 'Weeknight chili',
    ImageProvider? image,
    String? totalTimeLabel = '45 min',
    String? caloriesLabel = '520 kcal',
    List<Widget> badges = const [],
    VoidCallback? onTap,
  }) => RecipeCard(
    title: title,
    image: image,
    totalTimeLabel: totalTimeLabel,
    caloriesLabel: caloriesLabel,
    badges: badges,
    onTap: onTap,
  );

  Widget sized(Widget child) => SizedBox(width: 200, child: child);

  group(RecipeCard, () {
    testWidgets('shows the name, time, calories and badges', (tester) async {
      await tester.pumpDesignSystem(
        sized(
          card(
            badges: const [ShareBadge(kind: .joint, label: 'Shared')],
          ),
        ),
      );

      expect(find.text('Weeknight chili'), findsOneWidget);
      expect(find.text('45 min'), findsOneWidget);
      expect(find.text('520 kcal'), findsOneWidget);
      expect(find.text('Shared'), findsOneWidget);
    });

    testWidgets('sets the name in the serif, two lines at most', (
      tester,
    ) async {
      await tester.pumpDesignSystem(sized(card()));

      final title = tester.widget<Text>(find.text('Weeknight chili'));
      expect(title.style?.fontFamily, contains(AppFonts.serif));
      expect(title.maxLines, 2);
    });

    testWidgets('leaves out facts it does not have', (tester) async {
      await tester.pumpDesignSystem(
        sized(card(totalTimeLabel: null, caloriesLabel: null)),
      );

      expect(find.byIcon(Symbols.schedule_rounded), findsNothing);
      expect(find.byIcon(Symbols.local_fire_department_rounded), findsNothing);
      expect(find.byType(Wrap), findsNothing);
    });

    testWidgets('shows a placeholder without a photo', (tester) async {
      await tester.pumpDesignSystem(sized(card()));

      expect(find.byType(Image), findsNothing);
      expect(find.byIcon(Symbols.restaurant_rounded), findsOneWidget);
    });

    testWidgets('shows the photo in a 4:3 frame', (tester) async {
      await tester.pumpDesignSystem(sized(card(image: _pixel)));

      expect(tester.widget<Image>(find.byType(Image)).image, _pixel);
      final frame = tester.getSize(find.byType(AspectRatio));
      expect(frame.width / frame.height, RecipeCard.photoAspectRatio);
    });

    testWidgets('falls back to the placeholder when the photo fails', (
      tester,
    ) async {
      await tester.pumpDesignSystem(sized(card(image: _pixel)));
      final errorBuilder = tester
          .widget<Image>(find.byType(Image))
          .errorBuilder!;

      await tester.pumpDesignSystem(
        Builder(builder: (context) => errorBuilder(context, Exception(), null)),
      );

      expect(find.byIcon(Symbols.restaurant_rounded), findsOneWidget);
    });

    testWidgets('insets the photo inside the ink', (tester) async {
      await tester.pumpDesignSystem(sized(card(onTap: () {})));

      final ink = tester.getRect(find.byType(InkWell));
      final photo = tester.getRect(find.byType(AspectRatio));
      expect(photo.left - ink.left, RecipeCard.inset);
      expect(ink.right - photo.right, RecipeCard.inset);
      expect(photo.top - ink.top, RecipeCard.inset);
    });

    testWidgets('opens the recipe when tapped', (tester) async {
      var taps = 0;
      await tester.pumpDesignSystem(sized(card(onTap: () => taps++)));

      await tester.tap(find.byType(RecipeCard));
      expect(taps, 1);
    });

    testWidgets('reads as one button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpDesignSystem(sized(card(onTap: () {})));

      expect(
        tester.getSemantics(find.text('Weeknight chili')),
        isSemantics(
          label: 'Weeknight chili\n45 min\n520 kcal',
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      await tester.expectMeetsGuidelines(
        sized(
          card(
            onTap: () {},
            badges: const [ExperimentBadge(label: 'Experiment')],
          ),
        ),
      );
    });

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'recipe_card',
      width: 200,
      scenarios: {
        'with badges': card(
          badges: const [
            ShareBadge(kind: .joint, label: 'Shared'),
            ExperimentBadge(label: 'Experiment'),
          ],
        ),
        'long name, no nutrition': card(
          title: 'Grandma’s slow-braised short ribs with polenta',
          caloriesLabel: null,
        ),
      },
    );
  });
}
