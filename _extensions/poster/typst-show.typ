// initialise with defaults
#let (poster, frame) = poster-syndrome-setup()

#let qr = block(qrcode(
    "$url$".replace("\\", "") ,
    width: 2.5cm,
    ecl: "l",
    colors: (white, black),
    quiet-zone: 0,
  ))



$if(by-author)$
#let authors=(
$for(by-author)$
$if(it.name.literal)$
    ( name: [$it.name.literal$],
      affiliation: [$for(it.affiliations)$$it.name$$sep$, $endfor$],
      email: [$it.email$],
      orcid: [$it.orcid$]
    ),
$endif$
$endfor$
)
$endif$



#show: poster.with(
  title: "$title$",
  $if(subtitle)$
  subtitle: "$subtitle$",
  $endif$
  abstract: "$abstract$",
  authors: authors,  
  qr-code: qr,
  date: "$date$",
  background: _page-background,
)





