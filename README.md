# agyeponglawrence.com

An economist's playground: interactive notebooks where every chart comes with the Python and an Excel version. Built with [Quarto](https://quarto.org) and hosted on [Vercel](https://vercel.com). Every push to `main` goes live; every pull request gets its own preview link.

## Add something new

Every piece on the shelf is one folder in `shelf/`. Tags are free: whatever you put in `categories` shows up in the home page's filter bar.

### 1. A notebook, note or tutorial

1. Copy `shelf/_template/` to `shelf/<yyyy-mm-short-name>/` (folders starting with `_` are never published).
2. Edit the first cell of `index.ipynb`: `title`, `description` (one line), `date`, `type` (notebook, note, tutorial or tool), `nb` (next number), `categories` (your tags), and optionally `note` (one short line under the title). These fill the page header automatically.
3. Follow the template's shape: under each heading, 2–3 key-point bullets, then one short paragraph, then the chart. Put *What this doesn't tell us* and *Questions I still have* before *Rebuild it in Excel*.
4. Write and **run** the notebook so its charts are saved in the file. The site shows the saved outputs; it never re-runs your code.
5. Put `replication.xlsx` and any data files in the same folder.
6. Push:

   ```bash
   git add shelf/<folder>
   git commit -m "NB-007: short title"
   git push
   ```

Vercel rebuilds the site in a couple of minutes. If the build fails, the old site stays up and Vercel shows the error log.

**Charts:** use Plotly and keep `pio.renderers.default = "plotly_mimetype+notebook_connected"` from the template; charts stay interactive (hover, zoom, sliders). Code is folded behind "Show code" automatically. Hide a helper cell entirely with `#| include: false` as its first line.

**Featured piece:** set `featured: true` to put it in the home page hero. The newest featured piece wins. For the animated hero chart, add a `hero.csv` with columns `series,x,y` (one row per point; the first series is drawn in gold) and the `hero-*` fields shown in the template.

### 2. Upload on github.com

Same as above, without Git: open `shelf/` on GitHub, choose **Add file → Upload files**, drag in the folder's files (name the folder in the path box), and commit to `main`.

### 3. A link card (a piece that lives elsewhere)

Add a block to `shelf/links.yml`:

```yaml
- title: "Same shock, different pain"
  date: 2026-07-14
  path: https://ajaypong.substack.com/p/same-shock-different-pain
  where: Substack
  nb: NB-002
  categories: [inflation, regional]
```

### 4. A tool

Add a block to `tools.yml` (title, description, path, where).

## How it's organised

| Path | What it is |
|---|---|
| `index.qmd` | Home page: featured piece, shelf, tools, about |
| `shelf/` | One folder per piece, plus `links.yml` for link cards |
| `shelf/_template/` | Starting point for a new piece |
| `tools.yml` | Things I've built |
| `about.qmd` | About page, papers, CV |
| `_listings/` | Templates for the hero, shelf and tools sections |
| `_includes/site.html` | Hero chart animation and tag filter behaviour |
| `styles.scss`, `styles-dark.scss` | Colours and fonts, light and dark |
| `analytics.html` | Analytics snippet (Vercel Web Analytics) |
| `vercel.json`, `scripts/vercel-build.sh` | Vercel build: installs Quarto, renders to `_site/` |

## Hosting on Vercel

Vercel runs `scripts/vercel-build.sh`, which downloads Quarto (version pinned in the script) and runs `quarto render`. Notebooks are not re-executed, so no Python is needed on Vercel. To upgrade Quarto, change `QUARTO_VERSION` in the script.

## Preview locally

```bash
quarto preview
```

Scroll-driven stories: install the closeread extension once with `quarto add qmd-lab/closeread`, then use it in any `.qmd` piece.
