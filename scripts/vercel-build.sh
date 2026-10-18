#!/usr/bin/env bash
# Vercel build: install Quarto, then render the site into _site/.
# Notebooks are not re-executed; the site uses the outputs saved in each .ipynb.
set -euo pipefail

QUARTO_VERSION="1.10.19"
TOOLS="${HOME:-/tmp}/.quarto-tools"

if ! command -v quarto >/dev/null 2>&1; then
  mkdir -p "$TOOLS"
  curl -fsSL "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz" \
    | tar -xz -C "$TOOLS"
  export PATH="$TOOLS/quarto-${QUARTO_VERSION}/bin:$PATH"
fi

quarto --version
quarto render
