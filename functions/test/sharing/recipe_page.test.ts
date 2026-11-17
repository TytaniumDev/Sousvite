import { describe, expect, it } from 'vitest';

import {
  escapeHtml,
  renderMissingPage,
  renderRecipePage,
} from '../../src/sharing/recipe_page.js';
import type { SharedRecipe } from '../../src/sharing/shared_recipe.js';

const base: SharedRecipe = {
  title: 'Lasagna',
  yield: null,
  sourceName: null,
  sourceUrl: null,
  ingredients: [],
  steps: [],
};

describe('renderRecipePage', () => {
  it('escapes everything the user wrote', () => {
    const html = renderRecipePage({
      ...base,
      title: '<script>alert("x")</script>',
      ingredients: [{ title: "Mom's & dad's", items: ['<b>1</b> cup'] }],
    });

    expect(html).not.toContain('<script>alert');
    expect(html).toContain('&lt;script&gt;alert(&quot;x&quot;)&lt;/script&gt;');
    expect(html).toContain('<h3>Mom&#39;s &amp; dad&#39;s</h3>');
    expect(html).toContain('<li>&lt;b&gt;1&lt;/b&gt; cup</li>');
  });

  it('lists ingredients as bullets and steps as numbered sections', () => {
    const html = renderRecipePage({
      ...base,
      yield: 'Serves 6',
      ingredients: [{ title: null, items: ['2 eggs'] }],
      steps: [
        { title: 'Prep', items: ['Crack the eggs.'] },
        { title: null, items: ['Bake.'] },
      ],
    });

    expect(html).toContain('<p class="meta">Serves 6</p>');
    expect(html).toContain(
      '<h2>Ingredients</h2>\n<ul>\n<li>2 eggs</li>\n</ul>',
    );
    expect(html).toContain('<h2>Steps</h2>\n<h3>Prep</h3>\n<ol>');
    expect(html).toContain('<ol>\n<li>Bake.</li>\n</ol>');
  });

  it('leaves out empty parts', () => {
    const html = renderRecipePage(base);

    expect(html).not.toContain('<h2>');
    expect(html).not.toContain('From ');
  });

  it('credits the source of imported recipes', () => {
    expect(
      renderRecipePage({ ...base, sourceUrl: 'https://example.com/a' }),
    ).toContain(
      'From <a href="https://example.com/a" rel="nofollow noopener">example.com</a>',
    );
    expect(
      renderRecipePage({
        ...base,
        sourceName: 'Serious Eats',
        sourceUrl: 'https://example.com/a',
      }),
    ).toContain('>Serious Eats</a>');
    expect(renderRecipePage({ ...base, sourceName: 'Grandma' })).toContain(
      '<p class="meta">From Grandma</p>',
    );
  });

  it('asks search engines not to index shared recipes', () => {
    expect(renderRecipePage(base)).toContain(
      '<meta name="robots" content="noindex">',
    );
  });
});

describe('renderMissingPage', () => {
  it('says the link is gone', () => {
    expect(renderMissingPage()).toContain('<h1>Recipe not found</h1>');
  });
});

describe('escapeHtml', () => {
  it('escapes the five HTML special characters', () => {
    expect(escapeHtml(`<a href="x">&'`)).toBe(
      '&lt;a href=&quot;x&quot;&gt;&amp;&#39;',
    );
  });
});
