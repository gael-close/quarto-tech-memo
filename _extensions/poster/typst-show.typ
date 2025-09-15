// Inclide inline the content of https://github.com/baptiste/poster-syndrome/ for full control
// #import "@preview/poster-syndrome:0.1.0": *
#import "@preview/fontawesome:0.5.0": *
#import "@preview/codetastic:0.2.2": qrcode

// initialise with defaults
#let (poster, frame) = poster-syndrome-setup()

#let qr = block(qrcode(
    "$url$".replace("\\", "") ,
    width: 2.5cm,
    ecl: "l",
    colors: (white, _default-theme.palette.highlight.darken(40%)),
    quiet-zone: 0,
  ))



$if(by-author)$
#let authors=(
$for(by-author)$
$if(it.name.literal)$
    ( name: "$it.name.literal$",
      affiliation: [$for(it.affiliations)$$it.name$$sep$, $endfor$],
      email: "$it.email$".replace("\\", "") ,
      orcid: "$it.orcid$"
    ),
$endif$
$endfor$
)
$endif$

#let author-list = authors.map(it => it.name).join("\n")
#let affiliation = authors.at(0).affiliation



#show: poster.with(
  title: "$title$",
  abstract: "$abstract$",
  authors: author-list,
  affiliation: affiliation,
  qr-code: qr,
  date: "$date$",
  background: _page-background,
)





