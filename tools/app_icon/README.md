# App icon

The Sousvite icon is a cream spoon crossed with a herb-green leaf on a tangerine tile. `generate.mjs` holds the drawing and writes every icon file from it, so the platforms never drift apart. The design decision is in [DESIGN_SYSTEM.md §7.1](../../docs/DESIGN_SYSTEM.md).

## Regenerate

From the repo root, with Node 20+ and Playwright's Chromium installed (`npm i -g playwright && npx playwright install chromium`):

```sh
node tools/app_icon/generate.mjs
```

Commit everything it changes. Never edit the generated files by hand.

## How the drawing works

The mark is drawn upright in a 1024 grid: a spoon (an ellipse and a stadium) and a leaf (a blade with its midrib cut out, and a short stem below the crossing). The spoon turns 42° one way and the leaf 42° the other, and the pair is scaled about the center. Every shape becomes cubic Béziers, so the transforms are baked into plain path data that SVG and Android vector drawables both read.

Colors come from the design system: tangerine `#ff8f4f` to `#f26b2c`, cream `#fff8f2`, and herb green `#a4d48c`.

## What it writes

| File | For |
|---|---|
| `apps/sousvite/ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcon.png` | iOS light icon and the App Store, 1024, no alpha |
| `…/AppIcon-Dark.png` | iOS dark: brand-colored mark on a transparent background |
| `…/AppIcon-Tinted.png` | iOS tinted: grayscale mark the system tints |
| `apps/sousvite/android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` | Android adaptive icon (Android 8+) |
| `…/res/drawable/ic_launcher_{background,foreground,monochrome}.xml` | Its layers. The monochrome layer drives themed icons (Android 13+) |
| `…/res/mipmap-*/ic_launcher.png` | Android 7 and older |
| `apps/sousvite/web/favicon.svg`, `favicon.png` | Browser tab icon, mark drawn bigger to read at 16 px |
| `apps/sousvite/web/icons/Icon-{192,512}.png` | Web app home screen icons |
| `apps/sousvite/web/icons/Icon-maskable-{192,512}.png` | Full-bleed icons Android crops to its own shape |
| `apps/sousvite/web/icons/apple-touch-icon.png` | Safari "Add to Home Screen", 180 |
| `tools/app_icon/store/play-store-512.png` | Google Play listing icon (upload by hand) |
| `tools/app_icon/svg/*.svg` | Masters for design tools, in each appearance |

## Not done yet

- **iOS 26 Icon Composer file.** iOS 26 builds its clear and glass looks from the three PNGs. A layered `.icon` file from Apple's Icon Composer (Mac only) would give finer control; it can replace the asset catalog entry later.
- **Splash screen.** It still shows Flutter's default.
