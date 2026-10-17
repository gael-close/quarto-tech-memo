// Inlined slide theme — based on touying-quarto-clean, customised for quarto-tech-memo
// Fonts: Fira Sans / Fira Code / Fira Math
// Colors: Materia palette (https://bootswatch.com/materia/)
// Changes vs upstream: no italic anywhere, Materia colors, bold headings/titles,
//   black section-slide heading, ORCID restored, vendored here (no @preview/touying-quarto-clean)
#import "@preview/touying:0.6.1": *
#import "@preview/fontawesome:0.6.0": *

#set figure(supplement: none)
#show math.equation: set text(font: ("Fira Math",))
#show raw: set text(font: ("Fira Code",))

// ---------------------------------------------------------------------------
// Section slide — heading in neutral-darkest (regular weight, 30pt)
// ---------------------------------------------------------------------------
#let new-section-slide(self: none, body) = touying-slide-wrapper(self => {
  let main-body = {
    set align(left + horizon)
    set text(size: 30pt, fill: self.colors.neutral-darkest, weight: "regular", font: self.store.font-family-heading)
    utils.display-current-heading(level: 1)
  }
  self = utils.merge-dicts(self, config-page(margin: (left: 0.4in, right: 0.433in, top: 0.4in, bottom: 0.5in)))
  touying-slide(self: self, main-body)
})

// ---------------------------------------------------------------------------
// Content slide
// ---------------------------------------------------------------------------
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let header(self) = {
    set align(bottom)
    show: components.cell.with(inset: (x: 0in, bottom: 0em))
    set par(leading: 0.35em)
    set text(
      size: 26pt,
      fill: self.colors.neutral-darkest,
      weight: self.store.font-weight-heading,
      font: self.store.font-family-heading,
    )
    stack(
      dir: ttb,
      spacing: 0.1in,
      pad(left: 0.4in, right: 0.433in, utils.call-or-display(self, self.store.header)),
      line(length: 100%, stroke: 2pt + rgb("#179299")),
    )
  }
  let footer(self) = {
    set align(bottom)
    show: pad.with(left: 0.4in, right: 0.433in, bottom: 0.2in)
    set text(fill: rgb("#6c6f85"), size: 14pt, weight: "regular")
    utils.call-or-display(self, self.store.footer)
    h(1fr)
    context utils.slide-counter.display() + " / " + utils.last-slide-number
  }
  let self = utils.merge-dicts(self, config-page(
    header: header,
    footer: footer,
  ))
  touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
})

// ---------------------------------------------------------------------------
// Title slide — Deck title (x=0.2, y=2, W=12.9, H=1.5) & Deck subtitle (x=0.2, y=3.5, W=12.9, H=2)
// ---------------------------------------------------------------------------
#let title-slide(..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let body = {
    set text(fill: self.colors.neutral-darkest, weight: "regular")
    // Deck title box: x=0.2in, y=2.0in, W=12.9in, H=1.5in, 0.2in padding
    place(top + left, dx: 0.2in, dy: 2.0in,
      block(width: 12.9in, height: 1.5in, inset: 0.2in,
        align(left + bottom,
          text(
            size: self.store.font-size-title,
            fill: self.colors.neutral-darkest,
            weight: self.store.font-weight-title,
            font: self.store.font-family-heading,
            info.title,
          )
        )
      )
    )
    // Deck subtitle & metadata box: x=0.2in, y=3.5in, W=12.9in, H=2.0in, 0.2in padding
    place(top + left, dx: 0.2in, dy: 3.5in,
      block(width: 12.9in, height: 2.0in, inset: 0.2in,
        align(left + top, {
          if info.subtitle != none {
            text(
              size: self.store.font-size-subtitle,
              style: "normal",
              fill: self.colors.neutral-darkest,
              weight: self.store.font-weight-subtitle,
              font: self.store.font-family-body,
              info.subtitle,
            )
            v(0.8em)
          }
          if info.authors != none {
            let count = info.authors.len()
            let ncols = calc.min(count, 3)
            grid(
              columns: (1fr,) * ncols,
              row-gutter: 1em,
              ..info.authors.map(author => align(left)[
                #text(size: 18pt, weight: "regular")[#author.name]
                #if author.orcid != [] {
                  show link: set text(size: 14pt, fill: rgb("a6ce39"))
                  link("https://orcid.org/" + author.orcid.text)[#fa-orcid()]
                } \
                #text(size: 14pt, fill: rgb("#6c6f85"), style: "normal")[#author.email] \
                #text(size: 14pt, fill: rgb("#6c6f85"), style: "normal")[#author.affiliation]
              ])
            )
          }
          if info.date != none {
            block(text(size: 14pt, fill: rgb("#6c6f85"), if type(info.date) == datetime { info.date.display(self.datetime-format) } else { info.date }))
          }
        })
      )
    )
  }
  self = utils.merge-dicts(self, config-page(margin: 0in), config-common(freeze-slide-counter: true))
  touying-slide(self: self, body)
})

// ---------------------------------------------------------------------------
// Theme entry point
// ---------------------------------------------------------------------------
#let clean-theme(
  aspect-ratio: "16-9",
  handout: false,
  header: utils.display-current-heading(level: 2),
  footer: [],
  font-size: 18pt,
  font-family-heading: ("Fira Sans",),
  font-family-body: ("Fira Sans",),
  font-weight-heading: "regular",
  font-weight-body: "regular",
  font-weight-title: "regular",
  font-weight-subtitle: "regular",
  font-size-title: 30pt,
  font-size-subtitle: 18pt,
  // Materia palette defaults
  color-jet: rgb("212121"),
  color-accent: rgb("#1e66f5"),
  color-accent2: rgb("e51c23"),
  ..args,
  body,
) = {
  set text(size: font-size, font: font-family-body, fill: color-jet, weight: font-weight-body)
  show figure.caption: set text(size: 18pt, weight: "regular")

  show: touying-slides.with(
    config-page(width: 13.333in, height: 7.5in, margin: (top: 1.0in + 20pt, bottom: 0.5in, left: 0.4in, right: 0.433in), header-ascent: 20pt, fill: rgb("#fafafa")),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      handout: handout,
      enable-frozen-states-and-counters: false,
      show-hide-set-list-marker-none: true,
      show-strong-with-alert: false,
    ),
    config-methods(
      init: (self: none, body) => {
        show link: set text(fill: self.colors.primary)
        // Unordered list
        set list(indent: 1em, marker: (
          text(fill: self.colors.primary, font: "New Computer Modern")[ #sym.triangle.filled.r ],
          text(fill: self.colors.primary, font: "New Computer Modern")[ #sym.arrow],
        ))
        // Ordered list
        set enum(
          indent: 1em,
          full: true,
          numbering: (..nums) => {
            let nums = nums.pos()
            let num = nums.last()
            let level = nums.len()
            let format = ("1.", "i.", "a.").at(calc.min(2, level - 1))
            let result = numbering(format, num)
            text(fill: self.colors.primary, result)
          },
        )
        // Level-3 sub-headings: plain, no italic, no blue
        show heading.where(level: 3): title => {
          set text(size: 1.1em, fill: color-jet, font: font-family-body, weight: "regular", style: "normal")
          block(inset: (top: -0.5em, bottom: 0.25em))[#title]
        }
        set bibliography(title: none)
        body
      },
      alert: (self: none, it) => text(fill: self.colors.secondary, it),
    ),
    config-colors(
      primary: color-accent,
      secondary: color-accent2,
      neutral-lightest: rgb("#fafafa"),
      neutral-darkest: color-jet,
    ),
    config-store(
      header: header,
      footer: footer,
      font-family-heading: font-family-heading,
      font-family-body: font-family-body,
      font-size-title: font-size-title,
      font-size-subtitle: font-size-subtitle,
      font-weight-heading: font-weight-heading,
      font-weight-title: font-weight-title,
      font-weight-subtitle: font-weight-subtitle,
      ..args,
    ),
  )

  body
}

// Custom helpers (preserved from upstream)
#let fg = (fill: rgb("e64173"), it) => text(fill: fill, it)
#let bg = (fill: rgb("e64173"), it) => highlight(fill: fill, radius: 2pt, extent: 0.2em, it)
#let _button(self: none, it) = {
  box(inset: 5pt, radius: 3pt, fill: self.colors.primary)[
    #set text(size: 0.5em, fill: white)
    #sym.triangle.filled.r
    #it
  ]
}
#let button(it) = touying-fn-wrapper(_button.with(it))
