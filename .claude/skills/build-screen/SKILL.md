---
name: build-screen
description: Build or change a screen in the Sousvite app (a page, sheet, or section under apps/sousvite/lib/features/), including any new design_system widget it needs. Use for UI work in the app.
---

# Build a screen

The rules live in the docs and in `CLAUDE.md`. This is the order to apply them in, and the places threads usually trip. Don't restate a doc here; link it.

## 1. Read before you write

- The task's row in [docs/BUILD_PLAN.md](../../../docs/BUILD_PLAN.md) §6: which paths you own. §3.2 lists the shared files you may also touch.
- The screen's pattern in [docs/DESIGN_SYSTEM.md](../../../docs/DESIGN_SYSTEM.md) §10, and the components in §9.2.
- [docs/ENGINEERING.md](../../../docs/ENGINEERING.md) §5 (rebuild rules) and §6 (Riverpod).
- A finished feature to copy: `lib/features/recipe/` and its tests in `test/features/recipe/`.

## 2. Files in the feature folder

All under `apps/sousvite/lib/features/<name>/`:

| File | Holds |
|---|---|
| `presentation/<thing>_screen.dart` | The screen, plus one file per part it shows |
| `application/<thing>.dart` | `@riverpod` providers and notifiers, with `part '<thing>.g.dart';` |
| `<name>_routes.dart` | `<Name>Routes.path`, `.routes`, and `.location(id)` when the path has parameters |
| `<name>.dart` | The public surface. Export only what other features use |

`lib/app/router.dart` only composes `...<Name>Routes.routes`; you change it only when adding a feature. Import another feature only through its `<name>.dart`.

## 3. Shape the widget tree

- The screen widget watches as little as it can (the recipe screen watches only whether the recipe exists) and passes **ids** down.
- Each part is its own small `ConsumerWidget` that watches only what it renders: a `family` provider by id, narrowed with `.select(...)`. Return a record from `select` when a widget needs a few fields.
- Wrap an `AsyncValue` in `AsyncValueView(value: ..., data: ...)` from `lib/shared/widgets/`.
- List children get `ValueKey(id)`. Timers and animations go in their own small widget.
- No widget-returning helper methods; write a private `_Part` class instead.
- `ref.watch` in `build`, `ref.read` in callbacks.
- Navigate with `context.go(<Name>Routes.location(id))`, never a string.
- Layout with `ReadingColumn` (one column) or `PaneLayout` (a side pane), and `WindowSizeClass.of(context)` only for whole-window choices (DESIGN_SYSTEM.md §6.3); test width-dependent layouts with `testWidgetsAtEverySize`. Spacing, colors, and text only from design_system tokens (`AppSpacing.*`, `context.colors`, `context.appText`, ...). CI rejects `Color(0x`, `fontSize:`, `EdgeInsets.all(<number>)`, and `MediaQuery.sizeOf` in `apps/`.

## 4. Use design_system widgets, and feed them words and quantities

- Reach for a §9.2 component before writing your own. These widgets know nothing of l10n, Riverpod, or domain entities: every label is a parameter, so pass `context.l10n.<feature>_<key>`.
- Amounts are `Quantity`, never `double`. `AmountText` and `IngredientRow` take a `Quantity` and a unit word. Get the word from `l10n.unitWord(unit, quantity, countWord: line.countWord)` (`lib/shared/units/unit_words.dart`), which also handles count words like "clove" and "cloves". `AmountText.textFor(quantity, word)` gives the same text as a plain string.
- Map domain values onto the UI-side enums design_system defines (`MatchStatus`, `NutritionBasis`, `ShareBadgeKind`, `SyncIconStatus`) in the app.

## 5. A new design_system widget

Only when a second feature needs it (one feature's widget stays in that feature). Then, in `packages/design_system/`:

1. `lib/src/widgets/<name>.dart`, exported from `lib/design_system.dart`. Plain values and strings only; it may use `package:units`.
2. A test in `test/src/widgets/<name>_test.dart` with:
   - `designSystemGoldenTest(...)` from `test/helpers/golden.dart`, which renders light, dark, cooking light, cooking dark, and 200% text. Pass `width:` for widgets that fill their row. Run `flutter test --update-goldens` on Linux and commit both `goldens/ci/` and `goldens/linux/`.
   - `tester.expectMeetsGuidelines(widget)`. If the pixel contrast check misfires on thin text, pass `textContrast: false` with a comment and add the color pair to `test/src/tokens/contrast_test.dart`.
3. A Widgetbook entry in `apps/widgetbook/`: use cases with knobs in `lib/src/components/<name>.dart`, listed in `lib/src/directories.dart`. Bump the count in `test/src/directories_test.dart`, which fails until you do.
4. Add the widget to DESIGN_SYSTEM.md §9.2 in the same PR.

## 6. Strings

Add keys to `apps/sousvite/lib/l10n/arb/app_en.arb` in your feature's block, prefixed `<feature>_`, each with an `@key` description. Sentence case, no exclamation marks (DESIGN_SYSTEM.md §11). Run `flutter gen-l10n` in `apps/sousvite` and commit `lib/l10n/gen/`.

## 7. Tests

In `apps/sousvite/test/features/<name>/`, mirroring `lib/`:

- `tester.pumpApp(screen, overrides: [...])` from `test/helpers/`, overriding repository providers with the fakes in `test/helpers/fakes/` (`FakeRecipeRepository`, `RecipeFixtures`, ...).
- Assert rebuilds with `BuildCounter`: change one item and expect only that item's widget to rebuild. `recipe_screen_test.dart` shows the pattern.
- Use `pumpRouterApp` to check where the screen navigates.

## 8. Before you push

At the root: `dart run build_runner build --workspace` (no diff after). In each package you touched: `dart fix --apply`, `dart format lib test`, `flutter analyze lib test` with zero issues, and `very_good test` with the coverage gate (70 for the app, 90 for design_system and widgetbook). The full commands are in `CLAUDE.md`.
