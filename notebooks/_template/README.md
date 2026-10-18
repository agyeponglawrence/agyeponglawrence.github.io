# Notebook template

Folders starting with `_` are skipped when the site renders, so this one never goes live.

To start a new notebook:

1. Copy this folder to `notebooks/<short-name>/` (for example `notebooks/beveridge-curve/`).
2. Edit the front matter in the first cell of `index.ipynb`: title, description, date and categories.
3. Run the notebook locally so the outputs (charts and tables) are saved in the file. The site shows the saved outputs and doesn't re-run your code.
4. Put the Excel replication workbook in the same folder as `replication.xlsx`.
5. Commit and push. The site rebuilds itself.
