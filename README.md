# Conor O'Kelly — CV

**[View the live CV → https://c-okelly.github.io/cv_project/](https://c-okelly.github.io/cv_project/)**

A LaTeX CV (XeLaTeX), compiled to PDF and published automatically with GitHub
Actions. Every push to `main` builds the PDF and deploys it to GitHub Pages.

## What's in this repo

| Path | What it is |
| --- | --- |
| `main.tex` | The CV source (XeLaTeX) |
| `cv-style.cls` | Document class (Friggeri-style layout) |
| `fonts/` | Fonts used by the document |
| `build.sh` | Local build script |
| `site/index.html` | GitHub Pages viewer page |
| `.github/workflows/build-and-deploy.yml` | Builds + publishes on every push |

## Building the CV locally

You need XeLaTeX with a few extra packages (`fontspec`, `unicode-math`,
`textpos`, `enumitem`, `changepage`, `biblatex`, `tikz`, `geometry`, `hyperref`,
`parskip`, `afterpage`, `hyphenat`). A full TeX Live install covers all of them.

Then run:

```sh
./build.sh
```

The script locates `xelatex` (including the common macOS install paths) and,
if anything is missing, prints the exact install command for your OS. The PDF
is written to `build/Conor OKelly CV.pdf`.

To compile manually (equivalent to the script):

```sh
xelatex -interaction=nonstopmode -halt-on-error \
  -output-directory build -jobname "Conor OKelly CV" main.tex
```

### Install LaTeX

**macOS**

```sh
brew install --cask mactex        # full install (recommended)
# or, smaller:
brew install --cask basictex      # then install the extra packages separately
```

**Linux (Debian/Ubuntu)**

```sh
sudo apt-get update && sudo apt-get install -y texlive-full
```

## Automated build & GitHub Pages

On every push to `main`, [`.github/workflows/build-and-deploy.yml`](.github/workflows/build-and-deploy.yml):

1. Compiles `main.tex` to `cv.pdf` with XeLaTeX.
2. Publishes the PDF (plus a small viewer page) to GitHub Pages.
3. Uploads the PDF as a workflow artifact (`cv-pdf`).

### One-time setup

1. Make the repository **public** (Pages is free for public repos).
2. Enable Pages with the **GitHub Actions** source:
   *Settings → Pages → Build and deployment → Source → "GitHub Actions"*.
