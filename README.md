# agyeponglawrence.com

An economist's playground: analysis, data tools and research, plus interactive notebooks where every chart comes with the Python and an Excel version. Built with [Quarto](https://quarto.org) and hosted on [Vercel](https://vercel.com). Every push to `main` goes live; every pull request gets its own preview link.

## Add something new

There are two kinds of piece, sorted by where they live:

- **Notebooks** live on this site: one folder in `shelf/` each. They show on the Notebooks page. Until the first one is published, the home page hides its Notebooks section and the navbar leaves out the Notebooks link; when you publish the first, add the link back in `_quarto.yml` (the spot is marked).
- **Analysis** lives elsewhere (Substack, TL Economic Intelligence, LinkedIn). It shows on the Analysis page. Posts on your own Substack appear there automatically; everything else is one entry in `shelf/analysis.yml` each. A piece can also get a short **summary page** on this site (see 3 below), so readers get the findings without leaving.

The home page shows the newest three of each. Tags are free: whatever you put in `categories` shows up in that page's tag dropdown.

### 1. A notebook (notebook, note or tutorial)

1. Copy `shelf/_template/` to `shelf/<yyyy-mm-short-name>/` (folders starting with `_` are never published).
2. Edit the first cell of `index.ipynb`. These fields build the page for you:
   - `title`, `subtitle`, `description` (one line for the home page shelf), `date`, `type` (analysis, note, tutorial or tool), `nb` (next number), `categories` (your tags), optional `note` (one short line under the title).
   - `key-points`: 2–3 bullets shown in a box under the subtitle ("What you'll learn" for tutorials).
   - `notebook`, `excel`, `sources`: build the **Replicate this** section at the end automatically.
3. Write it like a Substack post: short sections, each with its own `##` subheading and one chart, then a final `## What this doesn't answer` (limits and open questions). Share buttons appear on the page and under every chart automatically.
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

### 3. Analysis (a piece published elsewhere)

**Your own Substack:** nothing to do. Every build reads the feed at `ajaypong.substack.com/feed` and adds any post that isn't already in `shelf/analysis.yml`, with its title, subtitle, date and link. The site rebuilds once a day (see *Daily rebuild* below), so a new post shows up within a day. To give a Substack post tags or an NB number, add it to `shelf/analysis.yml` with the same link: that entry replaces the automatic one.

**Anything else** (TL Economic Intelligence, LinkedIn): add a block to `shelf/analysis.yml`:

```yaml
- title: "Same shock, different pain"
  description: "One line for the shelf."
  date: 2026-07-14
  path: https://ajaypong.substack.com/p/same-shock-different-pain
  where: Substack
  nb: NB-002
  categories: [inflation, regional]
```

**A summary page** (recommended for your best pieces): copy `analysis/_template.qmd` to `analysis/<short-name>.qmd`, fill in the key points, add a chart image next to it, and delete the piece's entry from `shelf/analysis.yml` (the page replaces it, and the listing row then opens the page instead of the other site). The page gets the share bar, a "Read the full piece" button and the subscribe box automatically, and shows in the RSS feed. For a post on your own Substack, `source:` is the post's link, which stops the automatic import from listing it twice.

### 4. A tool

Copy `tools/export-concentration/` to `tools/<name>/` and edit its `index.qmd` (see `tools/README.md`). Each tool gets its own page with a screenshot, what it answers, an "Open the tool" button and related pieces; the newest one shows on the home page.

## How it's organised

| Path | What it is |
|---|---|
| `index.qmd` | Home page: opening, featured piece, newest analysis and notebooks, tools, subscribe |
| `notebooks.qmd` | Notebooks page: every notebook in `shelf/`, with a tag filter |
| `analysis/` | Summary pages for pieces published elsewhere; `_template.qmd` is the starting point |
| `analysis.qmd` | Analysis page: every piece in `shelf/analysis.yml`, with a tag filter |
| `shelf/` | One folder per notebook |
| `shelf/analysis.yml` | Analysis published elsewhere, written by hand |
| `shelf/substack.yml` | Generated at build time from the Substack feed; not committed |
| `shelf/_template/` | Starting point for a new notebook |
| `tools/` | Tools page and one folder per tool |
| `about.qmd` | About page |
| `research.qmd` | Research page: published papers |
| `_listings/` | Templates for the hero, the notebook and analysis lists, tools, and related pieces |
| `_filters/piece.lua` | Builds each piece's key-points box and Replicate section |
| `_includes/title-block.html` | Header on piece pages: kicker, title, tags, share bar |
| `_includes/site.html` | Hero chart, tag dropdown, share buttons, navbar highlight, mobile Subscribe pill, keyboard-friendly chart sliders |
| `_includes/skip.html` | "Skip to content" link |
| `_includes/analytics.html` | Analytics snippet (Vercel Web Analytics) |
| `styles.scss`, `styles-dark.scss` | Colours and fonts, light and dark |
| `vercel.json`, `scripts/vercel-build.sh` | Vercel build: installs Quarto, renders to `_site/` |
| `scripts/substack.lua` | Before each render: pulls Substack posts into `shelf/substack.yml`. If Substack can't be reached, the build carries on without them |
| `.github/workflows/daily-rebuild.yml` | Triggers a Vercel rebuild every morning so new Substack posts appear |
| `scripts/feed.lua` | Writes the RSS feed (`index.xml`) after each render: every notebook plus every analysis piece, linking to where each piece lives |

## Hosting on Vercel

Vercel runs `scripts/vercel-build.sh`, which downloads Quarto (version pinned in the script) and runs `quarto render`. Notebooks are not re-executed, so no Python is needed on Vercel. To upgrade Quarto, change `QUARTO_VERSION` in the script.

## Daily rebuild

The site only rebuilds when something changes, so a GitHub Action triggers a Vercel rebuild every morning. One-time setup:

1. In Vercel: **Project → Settings → Git → Deploy Hooks**, create a hook named `daily` for branch `main`, and copy its URL.
2. In GitHub: **Settings → Secrets and variables → Actions → New repository secret**, name `VERCEL_DEPLOY_HOOK`, paste the URL.
3. Optional check: **Actions → Daily rebuild → Run workflow**, then watch a new deployment start in Vercel.

## Preview locally

```bash
quarto preview
```

Scroll-driven stories: install the closeread extension once with `quarto add qmd-lab/closeread`, then use it in any `.qmd` piece.
