import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  const label = Text('2 tsp');

  /// Room around the ink, so taps can land outside it.
  Widget roomy(Widget child) => SizedBox.square(
    dimension: 120,
    child: Align(alignment: AlignmentDirectional.centerStart, child: child),
  );

  group(PaddedInkWell, () {
    testWidgets('pads its child evenly inside the ink', (tester) async {
      await tester.pumpDesignSystem(
        PaddedInkWell(
          onTap: () {},
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space2,
          child: label,
        ),
      );

      final ink = tester.getRect(find.byType(InkWell));
      final text = tester.getRect(find.byWidget(label));
      expect(text.left - ink.left, AppSpacing.space3);
      expect(ink.right - text.right, AppSpacing.space3);
      expect(text.top - ink.top, AppSpacing.space2);
      expect(ink.bottom - text.bottom, AppSpacing.space2);
    });

    testWidgets('pads by 4 dp unless told otherwise', (tester) async {
      await tester.pumpDesignSystem(PaddedInkWell(onTap: () {}, child: label));

      final ink = tester.getRect(find.byType(InkWell));
      final text = tester.getRect(find.byWidget(label));
      expect(text.left - ink.left, PaddedInkWell.minPadding);
      expect(text.top - ink.top, PaddedInkWell.minPadding);
    });

    test('keeps at least 4 dp of padding', () {
      expect(
        () => PaddedInkWell(onTap: null, horizontal: 2, child: label),
        throwsAssertionError,
      );
      expect(
        () => PaddedInkWell(onTap: null, vertical: 0, child: label),
        throwsAssertionError,
      );
    });

    test('takes one shape', () {
      expect(
        () => PaddedInkWell(
          onTap: null,
          borderRadius: AppRadii.borderSm,
          customBorder: const CircleBorder(),
          child: label,
        ),
        throwsAssertionError,
      );
    });

    testWidgets('gives the ink its corners', (tester) async {
      await tester.pumpDesignSystem(
        PaddedInkWell(
          onTap: () {},
          borderRadius: AppRadii.borderSm,
          child: label,
        ),
      );

      expect(
        tester.widget<InkWell>(find.byType(InkWell)).borderRadius,
        AppRadii.borderSm,
      );
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var taps = 0;
      await tester.pumpDesignSystem(
        PaddedInkWell(onTap: () => taps++, child: label),
      );

      await tester.tap(find.byWidget(label));
      expect(taps, 1);
    });

    testWidgets('takes taps across 48 dp around a smaller ink', (tester) async {
      var taps = 0;
      await tester.pumpDesignSystem(
        Center(
          child: roomy(
            Center(
              child: PaddedInkWell(
                onTap: () => taps++,
                child: const SizedBox.square(dimension: 8),
              ),
            ),
          ),
        ),
      );

      final ink = tester.getRect(find.byType(InkWell));
      expect(ink.size, const Size.square(16));
      const reach = PaddedInkWell.minTapTarget / 2 - 1;
      await tester.tapAt(ink.center + const Offset(reach, 0));
      await tester.tapAt(ink.center + const Offset(0, -reach));
      expect(taps, 2);

      await tester.tapAt(ink.center + const Offset(reach + 2, 0));
      expect(taps, 2);
    });

    testWidgets('places a smaller ink in its tap area by tapTargetAlignment', (
      tester,
    ) async {
      Widget inkAt(AlignmentGeometry alignment) => PaddedInkWell(
        onTap: () {},
        tapTargetAlignment: alignment,
        child: const SizedBox.square(dimension: 8),
      );
      double inkOffset() =>
          tester.getTopLeft(find.byType(InkWell)).dx -
          tester.getTopLeft(find.byType(PaddedInkWell)).dx;

      await tester.pumpDesignSystem(inkAt(Alignment.center));
      expect(inkOffset(), 16);

      await tester.pumpDesignSystem(inkAt(AlignmentDirectional.centerStart));
      expect(inkOffset(), 0);
    });

    testWidgets('lays out at least 48 dp, inside and out', (tester) async {
      await tester.pumpDesignSystem(
        PaddedInkWell(
          onTap: () {},
          child: const SizedBox(width: 8, height: 80),
        ),
      );

      final box = tester.renderObject<RenderBox>(find.byType(PaddedInkWell));
      const target = PaddedInkWell.minTapTarget;
      expect(box.size, const Size(target, 88));
      expect(tester.getSize(find.byType(InkWell)), const Size(16, 88));
      expect(box.getMinIntrinsicWidth(double.infinity), target);
      expect(box.getMaxIntrinsicWidth(double.infinity), target);
      expect(box.getMinIntrinsicHeight(double.infinity), 88);
      expect(box.getMaxIntrinsicHeight(double.infinity), 88);
      expect(box.getDryLayout(const BoxConstraints()), const Size(target, 88));
    });

    testWidgets('ignores taps without onTap', (tester) async {
      await tester.pumpDesignSystem(
        const PaddedInkWell(onTap: null, child: label),
      );

      await tester.tap(find.byWidget(label), warnIfMissed: false);
      expect(tester.takeException(), isNull);
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      // The text's color is the caller's; this checks the tap target.
      await tester.expectMeetsGuidelines(
        textContrast: false,
        Semantics(
          button: true,
          child: PaddedInkWell(
            onTap: () {},
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space4,
            child: label,
          ),
        ),
      );
    });

    // The ink only shows on hover, focus, or press, so each surface sits on
    // a tinted Material of its own shape to show where the ink reaches.
    designSystemGoldenTest(
      'pads its content evenly inside the ink',
      fileName: 'padded_ink_well',
      scenarios: {
        'label, 16 by 14': const _Tinted(
          shape: StadiumBorder(),
          child: PaddedInkWell(
            onTap: _noop,
            horizontal: AppSpacing.space4,
            vertical: 14,
            customBorder: StadiumBorder(),
            child: label,
          ),
        ),
        'tile, 4': const _Tinted(
          shape: RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
          child: PaddedInkWell(
            onTap: _noop,
            borderRadius: AppRadii.borderLg,
            child: SizedBox.square(dimension: 64, child: Placeholder()),
          ),
        ),
        'icon, 12': const _Tinted(
          shape: CircleBorder(),
          child: PaddedInkWell(
            onTap: _noop,
            horizontal: AppSpacing.space3,
            vertical: AppSpacing.space3,
            customBorder: CircleBorder(),
            child: Icon(Symbols.add_rounded),
          ),
        ),
      },
    );
  });
}

void _noop() {}

/// [child] on a tinted Material of [shape], so a golden shows the ink's
/// extent.
class const _Tinted({
  required final ShapeBorder shape,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final onTint = context.colors.onSecondaryContainer;
    return Material(
      color: context.colors.secondaryContainer,
      shape: shape,
      child: IconTheme.merge(
        data: IconThemeData(color: onTint),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: onTint),
          child: child,
        ),
      ),
    );
  }
}
