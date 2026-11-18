// Builds every app icon file from one drawing: the spoon and leaf mark.
//
//   node tools/app_icon/generate.mjs        (from the repo root)
//
// Needs Node 20+ and Playwright with Chromium, which renders the PNGs
// (`npm i -g playwright && npx playwright install chromium`).
// README.md in this folder explains the layers and what each file is for.

import { mkdirSync, writeFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, join } from 'node:path';
import { deflateSync } from 'node:zlib';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const app = join(root, 'apps', 'sousvite');

// Colors from docs/DESIGN_SYSTEM.md §7.1: a tangerine tile (brighter than the
// terracotta accent), cream (surface), herb green (primary, dark scheme).
const colors = {
  backgroundTop: '#ff8f4f',
  backgroundBottom: '#f26b2c',
  spoon: '#fff8f2',
  leaf: '#a4d48c',
  darkSpoon: '#ff8f4f',
  darkLeaf: '#a4d48c',
  tintedSpoon: '#ffffff',
  tintedLeaf: '#bdbdbd',
};

// ---------------------------------------------------------------------------
// Geometry. The mark is drawn upright in a 1024 grid, then each part is
// rotated and the whole mark scaled about the center. Every shape is reduced
// to cubic Béziers so the transforms can be baked into plain path data that
// SVG and Android vector drawables both read.

const KAPPA = 0.5523;

/** A closed shape: a start point and a list of cubic segments. */
const shape = (start, curves) => ({ start, curves });

const ellipse = (cx, cy, rx, ry) => {
  const kx = rx * KAPPA;
  const ky = ry * KAPPA;
  return shape([cx, cy - ry], [
    [[cx + kx, cy - ry], [cx + rx, cy - ky], [cx + rx, cy]],
    [[cx + rx, cy + ky], [cx + kx, cy + ry], [cx, cy + ry]],
    [[cx - kx, cy + ry], [cx - rx, cy + ky], [cx - rx, cy]],
    [[cx - rx, cy - ky], [cx - kx, cy - ry], [cx, cy - ry]],
  ]);
};

const line = (a, b) => [a, b, b];

const roundedRect = (x, y, w, h, r) => {
  const k = r * KAPPA;
  const [x2, y2] = [x + w, y + h];
  return shape([x + r, y], [
    line([x + r, y], [x2 - r, y]),
    [[x2 - r + k, y], [x2, y + r - k], [x2, y + r]],
    line([x2, y + r], [x2, y2 - r]),
    [[x2, y2 - r + k], [x2 - r + k, y2], [x2 - r, y2]],
    line([x2 - r, y2], [x + r, y2]),
    [[x + r - k, y2], [x, y2 - r + k], [x, y2 - r]],
    line([x, y2 - r], [x, y + r]),
    [[x, y + r - k], [x + r - k, y], [x + r, y]],
  ]);
};

const spoonParts = [
  ellipse(512, 150, 40, 56),
  roundedRect(501, 196, 22, 156, 11),
];

const leafParts = [
  // Blade, then its midrib, which the even-odd fill rule cuts out.
  shape([512, 96], [
    [[566, 128], [572, 180], [512, 204]],
    [[452, 180], [458, 128], [512, 96]],
  ]),
  shape([512, 128], [
    [[516, 160], [516, 180], [512, 196]],
    [[508, 180], [508, 160], [512, 128]],
  ]),
  roundedRect(500, 272, 24, 74, 12),
];

const rotateAbout = (degrees, [px, py]) => {
  const a = (degrees * Math.PI) / 180;
  const [c, s] = [Math.cos(a), Math.sin(a)];
  return ([x, y]) => [px + (x - px) * c - (y - py) * s, py + (x - px) * s + (y - py) * c];
};

/** Scales the mark (whose center is 512, 226) to `scale` and centers it. */
const placeMark = (scale) => ([x, y]) => [512 + (x - 512) * scale, 512 + (y - 226) * scale];

const mapShape = (s, f) => ({ start: f(s.start), curves: s.curves.map((c) => c.map(f)) });

const pathData = (shapes, offset = 0) => {
  const n = (v) => +(v + offset).toFixed(1);
  const p = ([x, y]) => `${n(x)} ${n(y)}`;
  return shapes
    .map((s) => `M${p(s.start)}` + s.curves.map((c) => `C${c.map(p).join(' ')}`).join('') + 'Z')
    .join('');
};

/** Path data for the spoon and the leaf, in the 1024 icon grid. */
const mark = (scale) => {
  const place = placeMark(scale);
  const spoon = spoonParts.map((s) => mapShape(mapShape(s, rotateAbout(-42, [512, 236])), place));
  const leaf = leafParts.map((s) => mapShape(mapShape(s, rotateAbout(42, [512, 236])), place));
  const all = [...spoon, ...leaf].flatMap((s) => [s.start, ...s.curves.flat()]);
  const reach = Math.max(...all.map(([x, y]) => Math.hypot(x - 512, y - 512)));
  return { spoon, leaf, reach };
};

// App icon scale. The favicon draws the mark bigger so it reads at 16 px;
const ICON_SCALE = 2.15;
const FAVICON_SCALE = 2.55;

// ---------------------------------------------------------------------------
// SVG

const svg = ({ scale = ICON_SCALE, background = true, radius = 0, spoon = colors.spoon, leaf = colors.leaf }) => {
  const m = mark(scale);
  const bg = background
    ? `<defs><linearGradient id="bg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${colors.backgroundTop}"/><stop offset="1" stop-color="${colors.backgroundBottom}"/></linearGradient></defs>` +
      `<rect width="1024" height="1024" rx="${radius}" fill="url(#bg)"/>`
    : '';
  return (
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">${bg}` +
    `<path fill="${spoon}" d="${pathData(m.spoon)}"/>` +
    `<path fill="${leaf}" fill-rule="evenodd" d="${pathData(m.leaf)}"/></svg>\n`
  );
};

// ---------------------------------------------------------------------------
// Android: adaptive icon layers as vector drawables. The 1024 grid is the
// 72 dp visible area, so the 108 dp layer is a 1536 viewport offset by 256.

const vector = (paths) =>
  '<?xml version="1.0" encoding="utf-8"?>\n' +
  '<!-- Generated by tools/app_icon/generate.mjs. Do not edit. -->\n' +
  '<vector xmlns:android="http://schemas.android.com/apk/res/android"\n' +
  '    android:width="108dp"\n    android:height="108dp"\n' +
  '    android:viewportWidth="1536"\n    android:viewportHeight="1536">\n' +
  paths
    .map(
      ({ color, d, evenOdd }) =>
        `    <path\n        android:fillColor="${color}"\n` +
        (evenOdd ? '        android:fillType="evenOdd"\n' : '') +
        `        android:pathData="${d}" />\n`,
    )
    .join('') +
  '</vector>\n';

const androidFiles = () => {
  const m = mark(ICON_SCALE);
  const res = join(app, 'android', 'app', 'src', 'main', 'res');
  const spoon = pathData(m.spoon, 256);
  const leaf = pathData(m.leaf, 256);
  return {
    [join(res, 'drawable', 'ic_launcher_foreground.xml')]: vector([
      { color: colors.spoon, d: spoon },
      { color: colors.leaf, d: leaf, evenOdd: true },
    ]),
    // Themed icons: Android recolors this single layer from the wallpaper.
    [join(res, 'drawable', 'ic_launcher_monochrome.xml')]: vector([
      { color: '#FFFFFFFF', d: spoon + leaf, evenOdd: true },
    ]),
    [join(res, 'drawable', 'ic_launcher_background.xml')]:
      '<?xml version="1.0" encoding="utf-8"?>\n' +
      '<!-- Generated by tools/app_icon/generate.mjs. Do not edit. -->\n' +
      '<shape xmlns:android="http://schemas.android.com/apk/res/android">\n' +
      `    <gradient\n        android:angle="270"\n        android:startColor="${colors.backgroundTop}"\n        android:endColor="${colors.backgroundBottom}" />\n` +
      '</shape>\n',
    [join(res, 'mipmap-anydpi-v26', 'ic_launcher.xml')]:
      '<?xml version="1.0" encoding="utf-8"?>\n' +
      '<!-- Generated by tools/app_icon/generate.mjs. Do not edit. -->\n' +
      '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n' +
      '    <background android:drawable="@drawable/ic_launcher_background" />\n' +
      '    <foreground android:drawable="@drawable/ic_launcher_foreground" />\n' +
      '    <monochrome android:drawable="@drawable/ic_launcher_monochrome" />\n' +
      '</adaptive-icon>\n',
  };
};

// ---------------------------------------------------------------------------
// PNGs. `opaque` keeps the alpha channel out, which the App Store requires.

const iosIcons = join(app, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset');
const androidRes = join(app, 'android', 'app', 'src', 'main', 'res');
const web = join(app, 'web');
const rounded = 1024 * 0.225;

const pngs = [
  // iOS: one 1024 image per appearance; Xcode makes every size from them.
  { path: join(iosIcons, 'AppIcon.png'), size: 1024, svg: svg({}), opaque: true },
  { path: join(iosIcons, 'AppIcon-Dark.png'), size: 1024, svg: svg({ background: false, spoon: colors.darkSpoon, leaf: colors.darkLeaf }) },
  { path: join(iosIcons, 'AppIcon-Tinted.png'), size: 1024, svg: svg({ background: false, spoon: colors.tintedSpoon, leaf: colors.tintedLeaf }) },
  // Android before 8.0, which has no adaptive icons.
  ...[['mdpi', 48], ['hdpi', 72], ['xhdpi', 96], ['xxhdpi', 144], ['xxxhdpi', 192]].map(([density, size]) => ({
    path: join(androidRes, `mipmap-${density}`, 'ic_launcher.png'),
    size,
    svg: svg({ radius: rounded }),
  })),
  // Web: favicon, home screen icons, and maskable icons for Android installs.
  { path: join(web, 'favicon.png'), size: 48, svg: svg({ scale: FAVICON_SCALE, radius: rounded }) },
  { path: join(web, 'icons', 'Icon-192.png'), size: 192, svg: svg({ radius: rounded }) },
  { path: join(web, 'icons', 'Icon-512.png'), size: 512, svg: svg({ radius: rounded }) },
  { path: join(web, 'icons', 'Icon-maskable-192.png'), size: 192, svg: svg({}), opaque: true },
  { path: join(web, 'icons', 'Icon-maskable-512.png'), size: 512, svg: svg({}), opaque: true },
  { path: join(web, 'icons', 'apple-touch-icon.png'), size: 180, svg: svg({}), opaque: true },
  // Store listings. Google Play rounds the corners itself.
  { path: join(root, 'tools', 'app_icon', 'store', 'play-store-512.png'), size: 512, svg: svg({}), opaque: true },
];

const textFiles = {
  [join(root, 'tools', 'app_icon', 'svg', 'app-icon.svg')]: svg({}),
  [join(root, 'tools', 'app_icon', 'svg', 'app-icon-dark.svg')]: svg({ background: false, spoon: colors.darkSpoon, leaf: colors.darkLeaf }),
  [join(root, 'tools', 'app_icon', 'svg', 'app-icon-tinted.svg')]: svg({ background: false, spoon: colors.tintedSpoon, leaf: colors.tintedLeaf }),
  [join(web, 'favicon.svg')]: svg({ scale: FAVICON_SCALE, radius: rounded }),
  ...androidFiles(),
};

const write = (path, data) => {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, data);
};

for (const [path, data] of Object.entries(textFiles)) write(path, data);

// Chromium draws each SVG onto a canvas; we encode the pixels ourselves so
// opaque icons are saved as RGB PNGs with no alpha channel at all.
const crcTable = Array.from({ length: 256 }, (_, n) => {
  let c = n;
  for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
  return c >>> 0;
});
const crc32 = (buf) => {
  let c = 0xffffffff;
  for (const b of buf) c = crcTable[(c ^ b) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
};
const chunk = (type, data) => {
  const head = Buffer.alloc(8);
  head.writeUInt32BE(data.length, 0);
  head.write(type, 4, 'ascii');
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(Buffer.concat([head.subarray(4), data])), 0);
  return Buffer.concat([head, data, crc]);
};
const encodePng = (rgba, size, opaque) => {
  const channels = opaque ? 3 : 4;
  const raw = Buffer.alloc(size * (size * channels + 1));
  for (let y = 0; y < size; y++) {
    raw[y * (size * channels + 1)] = 0; // no filter
    for (let x = 0; x < size; x++) {
      const from = (y * size + x) * 4;
      const to = y * (size * channels + 1) + 1 + x * channels;
      for (let i = 0; i < channels; i++) raw[to + i] = rgba[from + i];
    }
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(size, 0);
  ihdr.writeUInt32BE(size, 4);
  ihdr[8] = 8; // bit depth
  ihdr[9] = opaque ? 2 : 6; // RGB or RGBA
  return Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    chunk('IHDR', ihdr),
    chunk('IDAT', deflateSync(raw, { level: 9 })),
    chunk('IEND', Buffer.alloc(0)),
  ]);
};

const { chromium } = createRequire(import.meta.url)('playwright');
const browser = await chromium.launch();
const page = await browser.newPage();
for (const { path, size, svg: source, opaque } of pngs) {
  const base64 = await page.evaluate(
    async ({ source, size, opaque }) => {
      const image = new Image(size, size);
      image.src = `data:image/svg+xml;base64,${btoa(source)}`;
      await image.decode();
      const canvas = document.createElement('canvas');
      canvas.width = size;
      canvas.height = size;
      const context = canvas.getContext('2d');
      if (opaque) {
        context.fillStyle = '#ffffff';
        context.fillRect(0, 0, size, size);
      }
      context.drawImage(image, 0, 0, size, size);
      const bytes = context.getImageData(0, 0, size, size).data;
      let binary = '';
      for (let i = 0; i < bytes.length; i += 0x8000) {
        binary += String.fromCharCode(...bytes.subarray(i, i + 0x8000));
      }
      return btoa(binary);
    },
    { source, size, opaque: !!opaque },
  );
  write(path, encodePng(Buffer.from(base64, 'base64'), size, !!opaque));
}
await browser.close();

for (const [name, scale] of [['app icon', ICON_SCALE], ['favicon', FAVICON_SCALE]]) {
  console.log(`${name}: mark reaches ${(mark(scale).reach / 512).toFixed(2)} of the half-width`);
}
