#import "@preview/fontawesome:0.6.0": *

#show: clean-theme.with(
  aspect-ratio: "16-9",
  $if(handout)$
    handout: true,
  $endif$
  // Font size override
  $if(fontsize)$
    font-size: $fontsize$,
  $elseif(brand.typography.base.size)$
    font-size: $brand.typography.base.size$,
  $endif$
  // Color overrides (Materia defaults are in clean-theme)
  $if(jet)$
    color-jet: rgb("$jet$"),
  $elseif(brand.color.foreground)$
    color-jet: brand-color.foreground,
  $endif$
  $if(accent)$
    color-accent: rgb("$accent$"),
  $elseif(brand.color.primary)$
    color-accent: brand-color.primary,
  $endif$
  $if(accent2)$
    color-accent2: rgb("$accent2$"),
  $elseif(brand.color.secondary)$
    color-accent2: brand-color.secondary,
  $endif$
  // Title size overrides
  $if(font-size-title)$
    font-size-title: $font-size-title$,
  $elseif(brand.defaults.clean-typst.title-slide.title.size)$
    font-size-title: $brand.defaults.clean-typst.title-slide.title.size$,
  $endif$
  $if(font-size-subtitle)$
    font-size-subtitle: $font-size-subtitle$,
  $elseif(brand.defaults.clean-typst.title-slide.subtitle.size)$
    font-size-subtitle: $brand.defaults.clean-typst.title-slide.subtitle.size$,
  $endif$
)

#title-slide(
  title: [$title$],
  subtitle: [$subtitle$],
  authors: (
    $for(by-author)$
      $if(it.name.literal)$
          ( name: [$it.name.literal$],
            affiliation: [$for(it.affiliations)$$it.name$$sep$, $endfor$],
            email: [$it.email$],
            orcid: [$it.orcid$]),
      $endif$
    $endfor$
  ),
  date: [$date$],
)
