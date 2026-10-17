-- Drop .ignore divs entirely
function Div(elem)
  if elem.classes:includes("ignore") then
    return {}
  end
end

-- Remove {{< colbreak >}} paragraphs in revealjs
function Para(elem)
  if pandoc.utils.stringify(elem):match("^%s*{{<%s*colbreak%s*>}}%s*$") then
    return {}
  end
end

-- Convert .aside spans to a plain parenthetical in revealjs
function Span(span)
  if span.classes:includes("aside") then
    span.classes = span.classes:filter(function(c) return c ~= "aside" end)
    local out = pandoc.List({ pandoc.Str("[") })
    out:extend(span.content)
    out:insert(pandoc.Str("]"))
    return out
  end
end

-- Wrap second line after <br> in .slide-title-sub span (20% smaller)
function Header(elem)
  local br_idx = nil
  for i, inline in ipairs(elem.content) do
    if inline.t == "RawInline" and inline.format:match("html") and inline.text:lower():match("^<br%s*/?>$") then
      br_idx = i
      break
    end
  end
  if not br_idx then return nil end

  local title_inlines = {}
  local sub_inlines = {}
  for i, inline in ipairs(elem.content) do
    if i < br_idx then
      table.insert(title_inlines, inline)
    elseif i > br_idx then
      table.insert(sub_inlines, inline)
    end
  end

  elem.content = title_inlines
  table.insert(elem.content, pandoc.RawInline("html", "<br>"))
  table.insert(elem.content,
    pandoc.Span(sub_inlines, pandoc.Attr("", {"slide-title-sub"}, {})))
  return elem
end
