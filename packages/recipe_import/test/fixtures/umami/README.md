# Umami export fixtures

Pages in the shape of Umami's HTML export ("Export recipes", HTML format).
They are written for these tests, not taken from a real export, so the repo
holds no one's recipe library. The tests zip them up the way Umami does: one
folder per recipe book, one `.html` file per recipe.

| File | Covers |
|---|---|
| `skillet_chicken.html` | Every detail line (book, servings, total and active time), a photo, ingredient sections as bold items (one with a trailing colon), a step section as an underlined item, another as a bold word followed by a plain colon with an underlined "Method:" sub-heading under it, steps typed with their numbers ("1. "), a step that starts with a bold word, and notes over two paragraphs |
| `plain_toast.html` | The least Umami writes: a name, a book, and empty lists and notes |
