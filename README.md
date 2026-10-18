# agyeponglawrence.com

Source for Lawrence Agyepong's website: open research notebooks on the Canadian economy. Built with [Quarto](https://quarto.org) and published to GitHub Pages.

## How it's organised

| Path | What it is |
|---|---|
| `index.qmd` | Home page |
| `notebooks/` | One folder per notebook (`index.ipynb` + `replication.xlsx`) |
| `notebooks/_template/` | Starting point for a new notebook (not published) |
| `writing.qmd` | Past analysis and papers |
| `about.qmd` | About page |
| `_quarto.yml` | Site settings and navigation |
| `styles.scss` | Colours and fonts |
| `analytics.html` | Analytics snippet (GoatCounter) |

## Publishing

Every push to `main` runs `.github/workflows/publish.yml`, which renders the site and deploys it to GitHub Pages. Notebooks aren't re-executed during the build; the site shows the outputs saved in each `.ipynb`.

To preview locally: `quarto preview`.
