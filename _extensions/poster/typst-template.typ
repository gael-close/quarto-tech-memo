// Include inline the content of https://github.com/baptiste/poster-syndrome/ for full control
// And simplify
// #import "@preview/poster-syndrome:0.1.0": *

#import "@preview/fontawesome:0.6.0": *
#import "utils.typ": *

// in mm. SImilar to A3 a bit wider ~ 16/9
#let _default-container = (
  x: 0,
  y: 0,
  width: 500,
  height: 300,
)

//# height is irrelevant as it will be determined by content
#let _default-frames = (
  title:       (x: 10,   y: 5,      width: 480,  height: 0),
  qrcode:      (x: 465,  y: 2.5,      width: 0,    height: 0),
  main:        (x: 10,   y: 35,     width: 480, height: 875),)


#let theme-helper(
  palette: (
    base: luma(10%),
    fg: black,
    bg: white,
    contrast:navy,
    melon: aqua,
  ),
  fonts: (
    base: ("Arial"), 
    raw: "DejaVu Sans Mono",
    math: (
      "New Computer Modern Math",
    ), // good to have safe fallback
  ),
  overrides: (:),
) = {
  let tmp-theme = (
    palette: palette,
    text: (
      title: (
        font: fonts.base,
        size: 24pt,
        weight: "bold",
        fill: palette.contrast,
      ),
      author: (
        size: 16pt,
        weight: "regular",
        
      ),
      affiliation: (
        weight: "thin",
        fill: palette.contrast.lighten(0%),
        size: 12pt,
      ),
      date: (
        weight: "thin",
        size: 9pt,
        fill: palette.contrast.lighten(30%)
      ),
      heading: (
        size: 14pt,
        font: fonts.base,
        weight: "regular",
        fill: palette.contrast,
      ),
      subheading: (
        size: 12pt,
        font: fonts.base,
        features: (smcp: 1, c2sc: 1, onum: 1),
        weight: "regular",
        fill: palette.contrast,
      ),
      outlook: (fill: luma(30%)),
      default: (
        size: 11pt,
        font: fonts.base,
      ),
      raw: (font: fonts.raw),
      math: (font: fonts.math),
    ),
    par: (
      title: (leading: 0em, spacing: 0.3em),
      author: (leading: 0em, spacing: 0.3em),
      affiliation: (leading: 0em, spacing: 0.3em),
      date: (leading: 0em),
      subheading: (:),
      outlook: (justify: false),
      default: (justify: true, leading: 0.52em),
      raw: (:),
      math: (:),
    ),
  )

  // merge theme with overrides
  return dict-merge(tmp-theme, overrides)
}

#let _default-theme = theme-helper()

// from a theme list, create element-specific styles
#let create-styles(
  theme: _default-theme,
  tags: (
    // at a minimum, must have default par and text fields
    "default",
    "raw",
    "math",
  ),
) = {
  for t in tags {
    let tmp-text = if t in theme.text.keys() {
      theme.text.at(t)
    } else {
      theme.text.default
    }
    let tmp-par = if t in theme.par.keys() {
      theme.par.at(t)
    } else {
      theme.par.default
    }
    ((t): show-set(text-args: tmp-text, par-args: tmp-par))
  }
}


#let _page-background = {
  place(
    rect(
      width: 100%,
      height: 10%,
      fill: _default-theme.palette.contrast.lighten(60%).transparentize(50%),
      radius: 0mm,
    ),
  )

}

#let poster-syndrome(
  title: none, 
  subtitle: none,
  abstract: none,
  authors: none,
  affiliation: none,
  date: none,
  qr-code: none,
  credit: none,
  cover-image: none,
  background: none,
  foreground: none,
  // objects needed for layout and display
  frame: none,
  container: none,
  styles: none,
  palette: none,
  // further frames
  body,
) = {

  // set document

  set page(
    width: container.width * 1mm,
    height: container.height * 1mm,
    margin: 0pt,
    foreground: foreground,
    background: background,
  )


  show: styles.default
  show raw: styles.raw
  show math.equation: styles.math

  set strong(delta: 200)

  set list(marker: text([•], baseline: 0pt))

  show heading.where(level: 2): it => [
    #set align(left)
    #block(it.body)
  ]
  show heading.where(level: 2): styles.heading

  show heading.where(level: 3): it => [
    #set align(left)
    #block(it.body)
  ]
  show heading.where(level: 3): styles.subheading

  set image(width: 100%)

  show "•": text.with(weight: "extralight", fill: palette.contrast)
  show "·": text.with(weight: "extralight", fill: palette.contrast)

  set list(marker: text([•], baseline: 0pt))
  set enum(numbering: n => text(fill: palette.contrast.darken(20%))[#n ·])

  show bibliography: it => {
  show link: set text(fill: rgb("#483d8b"))

  set enum(numbering: n => text(fill: palette.contrast.darken(20%))[#n ·])
  it
  }

  show link: set text(fill: rgb("#483d8b")) // Needed here too for links in body text
  let count = authors.len()
  let ncols = calc.min(count, 3)
  
  // set fixed frames
  frame(tag: "title")[
    #show: styles.title
    #title #text(size: 20pt, weight: "regular")[| #subtitle]



    #grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author => align(left)[
        #show: styles.author
        #author.name
        #if author.orcid != [] {
          link("https://orcid.org/" + author.orcid.text)[
            #set text(size: 0.85em, fill: rgb("a6ce39"))
            #fa-icon("orcid")
          ]
        } \
        #show: styles.affiliation
        #author.affiliation

        #text(size: 8pt, weight: "thin")[
        #link("mailto:" + author.email.children.map(email => email.text).join())[#author.email]]
      ])
    )    
  ]


  frame(tag: "qrcode")[
    #if qr-code != none {
      qr-code
    }
  ]

  frame(tag:"main")[#columns(3)[
  *Summary.* #abstract

  #body
  ]]
}

#let poster-syndrome-setup(
  theme: _default-theme,
  frames: _default-frames,
  container: _default-container,
) = {
  // create styles for supplied theme elements
  let tags-in-use = (theme.text.keys(), theme.par.keys()).flatten().dedup()
  let styles = create-styles(theme: theme, tags: tags-in-use)

  let frame(tag: "none", body) = {
    let f = frames.at(tag)
    // show-set rule for that frame if defined
    show: {
      if tag in styles.keys() {
        styles.at(tag)
      } else {
        styles.default
      }
    }
    place(dx: f.x * 1mm, dy: f.y * 1mm, box(
      width: f.width * 1mm,
      height: f.height * 1mm,
    )[#body])
  }

  return (
    poster: poster-syndrome.with(
      styles: styles,
      palette: theme.palette,
      frame: frame,
      container: container,
    ),
    frame: frame,
  )
}

// Table style
#set table(stroke: none)
#show table.cell.where(y: 0): strong
// from the doc
#let frame(stroke) = (x, y) => (
  top: if y < 2 { stroke } else { 0pt },
  bottom: stroke,
)
#set table(
  // fill: (_, y) => if calc.odd(y) { rgb("EAF2F5") },
  stroke: frame(black),
)
#import "@preview/codetastic:0.2.2": qrcode

// Side note are not supported in poster
// Replace them with simple parenthesized text
#let note(body, ..arg) = [[#body]]

// Global block-quote styling
#show quote.where(block: true): set block(
  stroke: (left: 1.5pt + gray, rest: none),
  inset: (left: 1em),
  outset: (left: 0.5em, right: 0.5em),
)