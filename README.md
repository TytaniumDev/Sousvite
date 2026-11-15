# Sousvite

Recipes, accurate nutrition, grocery lists, and a cooking mode that does the math for you. One Flutter app for iOS, Android, and the web.

[![CI](https://github.com/TytaniumDev/Sousvite/actions/workflows/ci.yml/badge.svg)](https://github.com/TytaniumDev/Sousvite/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**[Open the web app](https://sousvite.web.app)** · **[Browse the Widgetbook](https://tytaniumdev.github.io/Sousvite/)**

> Sousvite is in active development and heading for a private beta. The web app updates on every push to `main`.

## TL;DR

Today your recipes live in one app and your nutrition tracking lives in another, and entering a recipe into a macro tracker is a chore. Sousvite puts them together.

- **Smart cooking mode.** Step text shows the scaled amounts inline and suggests which of *your* measuring cups and spoons to use, so you never flip back to the ingredient list.
- **Accurate nutrition.** Per batch and per serving, from USDA FoodData Central, with Open Food Facts for packaged products.
- **Easy capture.** Import from a URL or from Umami, or type a recipe and let the parser split amounts from ingredients. Organize steps into sections (like Prep) and recipes into folders.
- **Grocery lists.** Add a recipe's ingredients to your list, line by line.
- **Recipe experiments.** Try a variation, note what changed, then keep it as history or promote it to the new recipe.
- **Offline first.** The full app works signed out on one device. Optional Google or Apple sign-in syncs for free through your own Google Drive.
- **Sousvite Pro** adds our cloud sync and sharing recipes with others.

No AI features, no social feed, no daily food logging. Just recipes, done well.

## Docs

| Doc | What it covers |
|---|---|
| [Product requirements (PRD)](docs/PRD.md) | What we're building, for whom, and why |
| [Engineering design](docs/ENGINEERING.md) | Architecture and tech choices. The source of truth for how it's built |
| [Design system](docs/DESIGN_SYSTEM.md) | Tokens, components, patterns, and accessibility |
| [Build plan](docs/BUILD_PLAN.md) | The task breakdown and the rules for working in parallel |

Contributing, or working with an AI agent? [CLAUDE.md](CLAUDE.md) is the short version of the conventions.

## Repo layout

This is a [Dart pub workspace](https://dart.dev/tools/pub/workspaces): one root `pubspec.yaml`, one lockfile, one `flutter pub get`.

```
apps/sousvite/            The Flutter app. Features are folders in lib/features/
apps/widgetbook/          Widgetbook of every design system component
packages/design_system/   Tokens, theme, and shared widgets
packages/domain/          Entities, value objects, repository interfaces (pure Dart)
packages/data/            Drift database and repositories (pure Dart)
packages/units/           Exact quantities, units, and unit math (pure Dart)
packages/…                sync, ingredient_parser, recipe_import, nutrition, measuring
tools/usda_builder/       CLI that builds the bundled USDA database
functions/                Cloud Functions (TypeScript) and security rules tests
```

## Getting started

You need the Flutter version pinned in [`.fvmrc`](.fvmrc) (always the latest stable). With [FVM](https://fvm.app), `fvm install` reads it for you.

```sh
flutter pub get                            # at the repo root; resolves every package
dart run build_runner build --workspace    # after changing freezed, Riverpod, or Drift code

cd apps/sousvite && flutter run            # the app
cd apps/widgetbook && flutter run -d chrome  # the Widgetbook
```

Checks, run in each package you touch (CI runs the same):

```sh
dart format lib test
flutter analyze lib test
very_good test --coverage --min-coverage 90   # 70 for apps/sousvite
```

The Cloud Functions in `functions/` are a Node project (Node 24; the Firebase emulators need Java 21): `npm ci`, then `npm test`.

## License

[MIT](LICENSE)
