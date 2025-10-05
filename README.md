# Quarto Tech Memo

This is a [quarto extension](https://quarto.org/) to create brief technical memos in PDF 
with the modern and ⚡fast Typst engine (built into Quarto).
The memo style provides a professional single-column PDF layout 
with ample room for sidenotes and small figures in the margin.
Inspired by [Tufte handout style](https://rstudio.github.io/tufte/).
The intended use is for brief technical memos and preprints of scientific articles.
In addition, a 2-column compact variant and a 3-column A3 poster variants are provided.
For reference, a legacy IEEE paper style is also included---using the LaTeX engine.
Finally a slide deck variant using the [Clean Slide Theme](https://typst.app/universe/package/touying-quarto-clean/) is provided. 

The following screenshot shows all variants of the same document.
**All are formatted from the same source** in a few seconds
(the IEEE style, with the legacy Latex engine, dominates the rendering time).
All generated PDF files are included in the [examples](examples) folder.

<img width=800 src=examples/collage.png>

## Prerequisites

Install [Quarto](https://quarto.org/docs/get-started/),
then install extra dependencies with:

```bash
pip install invoke cookiecutter
# if the PDFlatex engine is to be used, install TinyTeX
quarto install tinytex
```

## Quick start

To render the provided PDF example from scratch:

```bash
cookiecutter -f gh:gael-close/quarto-tech-memo; cd new-dir;
quarto render new-tech-memo.md 
```

For the variant use the flags `--to memo2-typst` or `--to memo3-typst` or `--to slides-typst`.

Edit `new-tech-memo.md` in your favorite editor and re-run the render command or preview changes live with:

```bash
quarto preview new-tech-memo.md
```

To use in an existing Quarto project as an extension, run

```bash
quarto add gael-close/quarto-tech-memo
```

---

## Details

* The memo template is based on: https://github.com/kazuyanagimoto/quarto-academic-typst.
* The margin notes are formatted by the [marginalia](https://typst.app/universe/package/marginalia/) package.
* In markdown, margin notes are should created with the `.aside` class: 
  see https://quarto.org/docs/authoring/article-layout.html#asides. 
  Note that this should be inline with the surrounding pargaraph (like a footnote).
* Margin notes don't make sense in 2-column style. 
They are still included inline in the main paragraph nevertheless.
* The slides template is taken from https://typst.app/universe/package/touying-quarto-clean/.
* Custom Lua filters are included for various tweaks.

## Development

Run a test suite with [Invoke](https://www.pyinvoke.org/). 
This will format the example memo in all variants.

```bash
invoke test (--gh)
```

The `--gh` flag uses the GitHub repo instead of a local copy of the extension. 

### Lua filters

To run the Lua filter standalone on a test file `dev.md`:

```
cd _extensions/meme1/lua-filters
quarto pandoc dev.md -t typst --lua-filter custom.lua
```
