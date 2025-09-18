# Quarto Tech Memo

This is a [quarto extension](https://quarto.org/) to create brief technical memos in PDF 
with the modern and ⚡fast Typst engine (built into Quarto).
The memo style provides a professional single-column PDF layout 
with ample room for sidenotes and small figures in the margin.
Inspired by [Tufte handout style](https://rstudio.github.io/tufte/).
The intended use is for brief technical memos and preprints of scientific articles.
In addition, a 2-column compact variant and a 3-column A3 poster variants are provided.
For reference, a legacy IEEE paper style is also included---using the LaTeX engine.

The following screenshot (click image for a larger PDF) shows the 3 variants of the same document, plus the legacy IEEE style.
**All are formatted from the same source** in a few seconds
(the IEEE style, with the legacy Latex engine, dominates the rendering time).
All generated PDF files are included in the [examples](examples) folder.

<a href="examples/collage.pdf">
<img width=600 src=examples/collage.png>
</a>



## Quick start

To render the provided PDF example from scratch:

```bash
cookiecutter -f gh:gael-close/quarto-tech-memo; cd new-dir;
quarto render new-tech-memo.md 
```

For the variant use the flags `--to memo2-typst` or `--to memo3-typst`

Edit `new-tech-memo.md` in your favorite editor and re-run the render command or preview changes live with:

```bash
quarto preview new-tech-memo.md
```

To use in an existing Quarto project as an extension, run

```bash
quarto add https://github.com/gael-close/quarto-tech-memo/
```

---

## Details

* The template is based on: https://github.com/kazuyanagimoto/quarto-academic-typst.
* The margin notes are formatted by the [marginalia](https://typst.app/universe/package/marginalia/) package.
* In markdown, margin notes are should created with the `.aside` class: 
  see https://quarto.org/docs/authoring/article-layout.html#asides. 
  Note that this should be inline with the surrounding pargaraph (like a footnote).
* Margin notes don't make sense in 2-column style. 
They are still included inline in the main paragraph nevertheless.
* Custom Lua filters are included for various tweaks.

## Development

Run a test suite with [Invoke](https://www.pyinvoke.org/),
formatting the memo in all variants.

```bash
invoke test (--gh)
```

The --gh flag uses the GitHub repo instead of a local copy of the extension. 

### Lua filters

To run the Lua filter standalone on a test file `dev.md`:

```
cd _extensions/meme1/lua-filters
quarto pandoc dev.md -t typst --lua-filter custom.lua
```
