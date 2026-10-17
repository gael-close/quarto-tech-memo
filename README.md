# Quarto Tech Memo

> See the companion article for more background:
> G. Close, “Turning Your Notes into PDF Technical Memos and Data Science Reports,” Data Science Collective, Oct. 2025. Available: https://medium.com/data-science-collective/turning-your-notes-into-pdf-technical-memos-or-data-science-reports-ddd150273cc6

This is a [quarto extension](https://quarto.org/) to create brief technical memos in PDF 
with the modern and ⚡fast Typst engine (built into Quarto).
The memo style provides a professional single-column PDF layout 
with ample room for sidenotes and small figures in the margin.
Inspired by [Tufte handout style](https://rstudio.github.io/tufte/).
The intended use is for brief technical memos and preprints of scientific articles.
In addition, a 2-column compact variant and a 3-column A3 poster variants are provided.
For reference, a legacy IEEE paper style is also included---using the LaTeX engine.
Slide deck variants are provided as a PDF (Typst, based on the [Clean Slide Theme](https://typst.app/universe/package/touying-quarto-clean/)), as an editable PowerPoint file (`pptx`), and as a Reveal.js HTML deck.
Finally, an HTML landing page variant is included, suitable for publishing on GitHub Pages or as a project landing page.

The following screenshot shows all variants of the same document.
**All are formatted from the same source** in a few seconds
(the IEEE style, with the legacy Latex engine, dominates the rendering time).
All generated PDF files are included in the [examples](https://github.com/gael-close/quarto-tech-memo/tree/main/examples) folder.

<img width=800 src="https://raw.githubusercontent.com/gael-close/quarto-tech-memo/main/examples/collage.png">

## Usage as Python CLI tool

Install the quarto and the quarto-tech-memo tool with [uv](https://docs.astral.sh/uv/getting-started/installation/),
and download the example:

```bash
uv tool install quarto-cli --with typst
uv tool install git+https://github.com/gael-close/quarto-tech-memo
uvx cookiecutter -f gh:gael-close/quarto-tech-memo; cd new-dir;
```

Before rendering, verify that all required tools and fonts are present:

```bash
quarto-tech-memo --check
```

This checks for `quarto`, `typst`, `xelatex` (optional, needed for `--to ieee`),
and all required fonts (Fira Sans, Fira Math, Fira Code, TeX Gyre Termes).
It works on macOS, Linux, and Windows.

To render the provided example, use the newly installed `quarto-tech-memo` command 
to convert a markdown file to a polished PDF memo.
It is just a thin wrapper around the `quarto` command 
providing the extension installation on the first run.
 
```bash
quarto-tech-memo new-tech-memo.md (--to memo1) (--preview)
```

For the variants, use one of the flags `--to memo2`, `--to slides-pdf`, `--to slides-pptx`, `--to poster`, `--to ieee`, `--to page`, or `--to reveal`

Edit `new-tech-memo.md` in your favorite editor and re-run the render command
or preview changes (one every save) live with:

```bash
quarto-tech-memo new-tech-memo.md --preview
```

![](https://raw.githubusercontent.com/gael-close/quarto-tech-memo/main/examples/preview-mode.gif)

## HTML outputs

Two HTML output formats are provided, both styled with Fira Sans / Fira Code fonts to match the PDF suite.

### `--to page` — HTML landing page

A static HTML page suitable for publishing on GitHub Pages or as a project landing page.
Includes a right-sidebar table of contents, author metadata, abstract, and the full document content.
The `.ignore` section and the `colbreak` shortcode are suppressed.

```bash
quarto-tech-memo new-tech-memo.md --to page
```

<img width=800 src="https://raw.githubusercontent.com/gael-close/quarto-tech-memo/main/examples/thumbnail-page.png">

### `--to reveal` — Reveal.js slide deck

An interactive browser-based presentation using [Reveal.js](https://revealjs.com/), styled to match `slides-pdf` and `slides-pptx`.
Complements the `--to slides-pdf` PDF deck: use `slides-pdf` for print-ready handouts, `reveal` for live talks and web sharing.
Features include presenter mode (`S`), overview grid (`O`), and full embed so the HTML file is self-contained.

```bash
quarto-tech-memo new-tech-memo.md --to reveal
```

## Slide outputs

Three slide formats share the same basic styling, so the deck looks the same whichever you choose:

* `--to slides-pdf`: print-ready PDF deck (Typst).
* `--to slides-pptx`: editable PowerPoint deck, built from the reference template `_extensions/slides-pptx/template.pptx`.
* `--to reveal`: Reveal.js HTML deck for live talks and web sharing.

All use Fira Sans (headings and body), a 16:9 page of 13.333 × 7.5 in, a bottom-aligned slide title with a 2pt teal (`#179299`) rule below it, 18pt body text, and 14pt muted annotations (slide numbers).

```bash
quarto-tech-memo new-tech-memo.md --to slides-pptx
```

## Usage in an existing quarto project

To use in an existing Quarto project as an extension run:

```bash
# Install the extension (one time only)
quarto add gael-close/quarto-tech-memo
```

## Usage inside a data science project

See this repo https://github.com/gael-close/quarto-tech-paper for usage inside a [data science project](https://cookiecutter-data-science.drivendata.org/).

---

## Fonts

To match the PDF examples in the `examples/` folder,
the following fonts must be installed system-wide.
Otherwise, reasonable fallback fonts will be used.

**Typst-based formats** (memo1, memo2, slides-pdf, poster):

| Role | Font | Fallback |
|------|------|---------|
| Body / headings | [Fira Sans](https://fonts.google.com/specimen/Fira+Sans) | Arial (macOS/Windows), Liberation Sans (Linux) |
| Math equations | [Fira Math](https://github.com/firamath/firamath/releases) | New Computer Modern Math |
| Code / monospace | [Fira Code](https://github.com/tonsky/FiraCode/releases) | DejaVu Sans Mono |

**IEEE format** (LaTeX/XeLaTeX engine only):

| Role | Font |
|------|------|
| Body | [TeX Gyre Termes](https://www.gust.org.pl/projects/e-foundry/tex-gyre/termes) |
| Math | TeX Gyre Termes Math |

TeX Gyre Termes is bundled with most TeX distributions (e.g. TinyTeX via `quarto install tinytex`) and may already be available if LaTeX is installed.

---

## Details

* Section headings are marked with single `#`. 
Adjust the [Typst option](https://quarto.org/docs/reference/formats/typst.html) 
`shift-heading-level-by: -1` to fit your convention.
* The memo template is based on: https://github.com/kazuyanagimoto/quarto-academic-typst.
* The margin notes are formatted by the [marginalia](https://typst.app/universe/package/marginalia/) package.
* In markdown, margin notes are should created with the `.aside` class: 
  see https://quarto.org/docs/authoring/article-layout.html#asides. 
  Note that this should be inline with the surrounding pargaraph (like a footnote).
* Margin notes don't make sense in 2-column style. 
They are still included inline in the main paragraph nevertheless.
* The slides template is taken from https://typst.app/universe/package/touying-quarto-clean/ and is inlined into the extension (no external package dependency at render time).
* The HTML landing page uses a custom Bootstrap SCSS theme with Fira Sans / Fira Code fonts to match the PDF output.
* Custom Lua filters are included for various tweaks.
* To get the ORCID icon, download the [fontawesome desktop variant](https://fontawesome.com/download).

## Development

### Full test suite
Run the full test suite with [Task](https://taskfile.dev/).
This will format the example memo in all variants (memo1, memo2, poster, slides-pdf, slides-pptx, ieee, page), save the rendered PDFs, PPTX, HTML files, and screenshots.

```bash
task test           # run from local extension
#task test GH=true  # run from GitHub repo
task save
```

The `GH=true` flag uses the GitHub repo instead of a local copy of the extension.
To skip the legacy IEEE format (requires a LaTeX installation via `quarto install tinytex`),
edit `FORMATS` in `Taskfile.yml` to remove `ieee`.

To render a single format:

```bash
task render-format FMT=memo1
```

To benchmark the conversion time for a given format:

```bash
task conversion-time FORMAT=memo1-typst
```

### Lua filters

To run the Lua filter standalone on a test file `dev.md`:

```bash
cd _extensions/memo1
quarto pandoc dev.md -t typst --lua-filter custom.lua
```

### Run as uv tool

Install from GitHub (recommended):

```bash
uv tool install git+https://github.com/gael-close/quarto-tech-memo --force
```

Or install from a local copy of the repo for development:

```bash
z quarto-tech-memo
uv tool install . -e
```


