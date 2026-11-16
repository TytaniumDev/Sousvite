# URL import fixtures

Small pages in the shapes real recipe sites use. They are written for these
tests rather than saved from the sites, so the repo holds no one else's
recipe text. Each one is named for the markup pattern it covers:

| File | Pattern |
|---|---|
| `json_ld_graph.html` | WordPress Recipe Maker and Yoast: a `@graph` with the recipe beside the page, `HowToSection`s, HTML entities, ISO times |
| `json_ld_array.html` | A top-level array, `@type` as a list, steps as one string with a line per step, yield as text |
| `json_ld_main_entity.html` | The recipe as a page's `mainEntity`, `HowToStep`s with `name` only, image as an object |
| `microdata.html` | Older sites: `itemscope itemtype="https://schema.org/Recipe"`, instructions in a list, times in `content` |
| `heuristics.html` | No markup: an `<h1>`, then lists under "Ingredients" and "Directions" headings |
| `no_recipe.html` | An article with no recipe |
