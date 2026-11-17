import type { SharedRecipe, SharedSection } from './shared_recipe.js';

/** Escapes text for HTML element content and quoted attributes. */
export const escapeHtml = (text: string): string =>
  text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');

// Colors are the light and dark `surface`, `on-surface`,
// `on-surface-variant`, and `primary` roles from DESIGN_SYSTEM.md §3, and
// the fonts are the app's (§4), so the page looks like Sousvite.
const styles = `
:root{color-scheme:light dark;--bg:#fff8f2;--fg:#1e1b16;--muted:#48473a;--accent:#3f692d}
@media (prefers-color-scheme:dark){:root{--bg:#16130e;--fg:#e9e1d8;--muted:#cac7b6;--accent:#a4d48c}}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--fg);font:16px/1.5 'Plus Jakarta Sans',system-ui,sans-serif}
main{max-width:680px;margin:0 auto;padding:32px 16px 64px}
h1,h2,h3{font-family:Newsreader,Georgia,serif;font-weight:500;line-height:1.2}
h1{font-size:2.25rem;margin:0 0 8px}
h2{font-size:1.5rem;margin:32px 0 8px}
h3{font-size:1.125rem;margin:16px 0 4px}
p.meta{color:var(--muted);margin:0}
a{color:var(--accent)}
li{margin:4px 0}
footer{margin-top:48px;color:var(--muted);font-size:.875rem}
`;

const page = (title: string, body: string): string =>
  `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="noindex">
<title>${escapeHtml(title)}</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Newsreader:opsz,wght@6..72,500&family=Plus+Jakarta+Sans:wght@400;600&display=swap">
<style>${styles}</style>
</head>
<body><main>
${body}
<footer>Shared from <a href="https://sousvite.web.app/">Sousvite</a></footer>
</main></body>
</html>
`;

const section = (value: SharedSection, list: 'ul' | 'ol'): string => {
  const heading =
    value.title === null ? '' : `<h3>${escapeHtml(value.title)}</h3>\n`;
  const items = value.items
    .map((item) => `<li>${escapeHtml(item)}</li>`)
    .join('\n');
  return `${heading}<${list}>\n${items}\n</${list}>`;
};

const source = (recipe: SharedRecipe): string => {
  if (recipe.sourceUrl !== null) {
    const label = recipe.sourceName ?? URL.parse(recipe.sourceUrl)?.hostname;
    return `<p class="meta">From <a href="${escapeHtml(recipe.sourceUrl)}" rel="nofollow noopener">${escapeHtml(label ?? recipe.sourceUrl)}</a></p>`;
  }
  return recipe.sourceName === null
    ? ''
    : `<p class="meta">From ${escapeHtml(recipe.sourceName)}</p>`;
};

/**
 * The view-only page for a shared recipe (PRD 7.10). Keeps the source
 * attribution of imported recipes (PRD §10) and asks search engines not to
 * index it.
 */
export const renderRecipePage = (recipe: SharedRecipe): string => {
  const parts = [
    `<h1>${escapeHtml(recipe.title)}</h1>`,
    recipe.yield === null
      ? ''
      : `<p class="meta">${escapeHtml(recipe.yield)}</p>`,
    source(recipe),
    recipe.ingredients.length === 0 ? '' : '<h2>Ingredients</h2>',
    ...recipe.ingredients.map((value) => section(value, 'ul')),
    recipe.steps.length === 0 ? '' : '<h2>Steps</h2>',
    ...recipe.steps.map((value) => section(value, 'ol')),
  ];
  return page(recipe.title, parts.filter((part) => part !== '').join('\n'));
};

/** The page for a link that was turned off or never existed. */
export const renderMissingPage = (): string =>
  page(
    'Recipe not found',
    '<h1>Recipe not found</h1>\n<p class="meta">This link was turned off, or the address is wrong.</p>',
  );
