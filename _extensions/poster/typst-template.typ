// Imported and simplified from https://github.com/baptiste/poster-syndrome/

#import "utils.typ": *

// in mm. SImilar to A3 a bit wider ~ 16/9
#let _default-container = (
  x: 0,
  y: 0,
  width: 500,
  height: 300,
)

#set text(size: 12pt)
//# height is irrelevant as it will be determined by content
#let _default-frames = (
  title:       (x: 10,   y: 5,      width: 480,  height: 0),
  authors:     (x: 10,   y: 15,     width: 480, height: 0),
  qrcode:      (x: 465,  y: 2.5,      width: 0,    height: 0),
  main:        (x: 10,   y: 35,     width: 480, height: 875),)


#let theme-helper(
  palette: (
    base: luma(10%),
    fg: black,
    bg: white,
    highlight:navy,
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
        size: 1.5em,
        weight: "bold",
        fill: palette.contrast,
      ),

      author: (
        size: 1.2em,
        weight: "regular",
        fill: palette.highlight.darken(40%),
      ),
      affiliation: (
        font: fonts.raw,
        weight: 300,
        fill: palette.highlight.darken(40%),
        size: 1em,
      ),
      date: (
        font: fonts.raw,
        fill: palette.highlight.darken(40%), size: 1em),
      
      heading: (
        size: 1.7em,
        font: fonts.base,
        weight: "regular",
        fill: palette.highlight.darken(40%),
      ),
      subheading: (
        size: 1.2pt,
        font: fonts.base,
        features: (smcp: 1, c2sc: 1, onum: 1),
        weight: "regular",
        fill: palette.highlight.darken(40%),
      ),
      outlook: (fill: luma(30%)),
      default: (
        size: 1em,
        font: fonts.base,
      ),
      raw: (font: fonts.raw),
      math: (font: fonts.math),
    ),
    par: (
      title: (leading: 0.5em),
      subtitle: (:),
      author: (leading: 0.8em),
      affiliation: (leading: 0.8em),
      date: (leading: 0.8em),
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

  show "•": text.with(weight: "extralight", fill: palette.highlight)
  show "·": text.with(weight: "extralight", fill: palette.highlight)

  set list(marker: text([•], baseline: 0pt))
  set enum(numbering: n => text(fill: palette.highlight.darken(20%))[#n ·])

  show bibliography: it => {
  show link: set text(fill: palette.contrast.darken(40%))

  set enum(numbering: n => text(fill: palette.highlight.darken(20%))[#n ·])
  it
  }

  // set fixed frames

  frame(tag: "title")[
    #show: styles.title
    #title
  ]
  frame(tag: "authors")[
    #show: styles.author
    #authors | #date
    // #show: styles.affiliation 
    // #affiliation 
    // #show: styles.date
    
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