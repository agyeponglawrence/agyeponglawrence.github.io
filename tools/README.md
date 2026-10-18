# Tools

One folder per tool, each with an `index.qmd`. Copy `export-concentration/` to add a new one.

- Front matter: `title`, `description` (one line for the card), `added` (date; newest shows on the home page), `where`, `tool-url`.
- Screenshots: put them in the folder (`.png` or `.webp`) and list them inside the `.la-tool-shot` block as `![](screenshot.webp){fig-alt="..."}`.
- Related notebooks: set `include: categories:` in the listing to the shelf tag that matches the tool.
