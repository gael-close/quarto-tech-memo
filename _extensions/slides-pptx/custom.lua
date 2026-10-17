-- Drop .ignore divs entirely
function Div(elem)
  if elem.classes:includes("ignore") then
    return {}
  end
end

-- Remove {{< colbreak >}} paragraphs in pptx
function Para(elem)
  local text = pandoc.utils.stringify(elem)
  if text:match("^%s*{{<%s*colbreak%s*>}}%s*$") or text == "" then
    if #elem.content == 0 or text:match("colbreak") then
      return {}
    end
  end
end

-- Convert .aside spans to a plain parenthetical in pptx
function Span(span)
  if span.classes:includes("aside") then
    span.classes = span.classes:filter(function(c) return c ~= "aside" end)
    local out = pandoc.List({ pandoc.Str("[") })
    out:extend(span.content)
    out:insert(pandoc.Str("]"))
    return out
  end
end

-- Replace <br> in headers with a line break
function Header(elem)
  return elem:walk({
    RawInline = function(inline)
      if inline.format:match("html") and inline.text:lower():match("^<br%s*/?>$") then
        return pandoc.LineBreak()
      end
    end
  })
end
