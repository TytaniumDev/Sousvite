# Parser corpus

Ingredient lines with the result the parser should give for each one (ENGINEERING.md §12). The parser's corpus test reads these files and reports the pass rate.

| File | What it holds |
|---|---|
| `real_lines.jsonl` | About 2,300 real lines from recipe sites, labeled by hand. Each line appears once, with no recipe titles or sources |
| `cases.jsonl` | Hand-written lines that cover each case in ENGINEERING.md §12 on purpose, tagged by case |

Every parsing bug found later becomes a new line here: a real line goes in `real_lines.jsonl`, and a made-up one that shows a case goes in `cases.jsonl`.

## Format

[JSON Lines](https://jsonlines.org): one JSON object per line, UTF-8. A field that has no value is left out, never `null` or `""`.

```json
{"text": "1 (15 oz) can black beans, drained", "quantity": "1", "unit": "can", "package": {"quantity": "15", "unit": "ounce"}, "name": "black beans", "preparation": "drained"}
{"text": "2–3 large cloves garlic", "quantity": "2", "quantityMax": "3", "unit": "clove", "size": "large", "name": "garlic"}
{"text": "Salt to taste", "name": "Salt", "preparation": "to taste"}
{"text": "For the sauce:", "heading": "sauce"}
```

| Field | Meaning |
|---|---|
| `text` | The line exactly as written, including odd spacing, Unicode, and emoji |
| `heading` | Set only when the line is a section heading ("For the sauce:", "Dressing:"), to the heading's title. A heading has no other fields |
| `quantity` | The amount as a reduced fraction string: `"3/2"`, `"1"`, `"27/2"`. This is the form `Quantity.toString()` prints. Decimals, Unicode fractions, mixed numbers, and number words all become fractions ("1.5", "1 ½", and "one and a half" are all `"3/2"`; "a" and "an" are `"1"`; "half" is `"1/2"`; "a dozen" is `"12"`) |
| `quantityMax` | The top of a range ("2–3", "2 to 3", "2 or 3"). `quantity` is the bottom |
| `unit` | The unit, when one comes before the name. A `Unit` enum name where one exists (`teaspoon`, `tablespoon`, `fluidOunce`, `cup`, `pint`, `quart`, `gallon`, `milliliter`, `liter`, `gram`, `kilogram`, `ounce`, `pound`, `pinch`, `piece`), otherwise one of the count nouns below |
| `size` | A size word or measure that describes each item: "large", "extra-large", "medium-sized", "2-inch" |
| `name` | The ingredient as written in the line, so it is always a substring of `text`. A leading "of" is left out |
| `preparation` | Everything else about the ingredient: preparation, notes, "to taste", "optional", "for serving", alternatives in parentheses. Parts appear in the order they are in the line, joined with `", "` |
| `package` | The size of one container, for a count of containers: "1 (15 oz) can" and "15 oz can" are `quantity` 1, `unit` `can`, and `package` `{"quantity": "15", "unit": "ounce"}` |
| `alternate` | The same amount in another unit: "1 cup (240 ml)", "1 cup/150 grams", "(about 12 ounces)", "3 tbsp sugar, 36 grams" |

`package` and `alternate` are objects with `quantity`, `unit`, and `quantityMax` when they are a range ("1 (13- to 14-ounce) can").

`cases.jsonl` lines also have `tags`, a list naming the cases a line covers (`unicode-fraction`, `range`, `unit-alias`, `package`, `heading`, and so on), so a failure report can be grouped by case.

### Count nouns

Units the `Unit` enum does not have yet. The parser reports them so the editor can show them, and nutrition treats them as counts.

`bag`, `block`, `bottle`, `box`, `bulb`, `bunch`, `can`, `carton`, `clove`, `container`, `cube`, `dash`, `drop`, `ear`, `fillet`, `handful`, `head`, `inch`, `jar`, `knob`, `leaf`, `loaf`, `package`, `packet`, `scoop`, `sheet`, `slice`, `splash`, `sprig`, `stalk`, `stick`, `strip`, `tube`.

Aliases map to one of these: plurals ("cloves"), "tin" to `can`, "pkg" to `package`, "rib" to `stalk`, "leaves" to `leaf`.

## Labeling rules

- **A unit only counts before the name.** "3 cloves garlic" has `unit` `clove` and `name` "garlic", but "3 garlic cloves" has no unit and `name` "garlic cloves".
- **Alternatives stay in the name** when they are a list of ingredients ("2 cups chicken stock, water or dashi"). Alternatives in parentheses or after "such as" go in `preparation`.
- **Adjectives before the name stay in the name,** even with commas ("boneless, skinless chicken thighs", "1 cup chopped onion"). Preparation after the name goes in `preparation` ("1 onion, diced").
- **Modifiers of the amount** ("heaping", "packed", "scant") go in `preparation`. "About" and "~" are dropped.
- **"Juice of 1 lemon"** is `quantity` 1, `name` "lemon", `preparation` "Juice". "Zest of", "rind of", and "juice and zest of" work the same way.
- **"Plus" amounts** stay in `preparation` ("1 cup plus 2 tablespoons flour" has `preparation` "plus 2 tablespoons").
- **Bullets, emoji, and invisible characters** are ignored.
- **The parser sees one line at a time.** A bare title such as "Peach salsa" is labeled as an ingredient name, because nothing in the line says it is a heading. Only "For the …" and lines ending in ":" are headings.
- Lines that are not an ingredient or a heading (a step, nutrition facts, a note on its own) are not in the corpus.

## Comparing results

A line passes when every field matches:

- `quantity`, `quantityMax`, and `unit` match exactly, as do those inside `package` and `alternate`.
- Text fields (`name`, `preparation`, `size`, `heading`) match after lowercasing, removing punctuation, and collapsing whitespace, so "Salt," and "salt" match.
- A field the fixture leaves out must be empty in the result.
