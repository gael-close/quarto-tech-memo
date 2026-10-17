-- Convert .aside spans to a plain parenthetical in slides
function Span(span)
  if span.classes:includes("aside") then
    span.classes = span.classes:filter(function(c) return c ~= "aside" end)
    local out = pandoc.List({ pandoc.Str("[") })
    out:extend(span.content)
    out:insert(pandoc.Str("]"))
    return out
  end
end

-- Add wideblock div and ignore environments
function Div(elem)
  if elem.classes:includes("ignore") then
    return {}
  end
  return nil
end

-- Remove {{< colbreak >}} paragraphs in slides
function Para(elem)
  local text = pandoc.utils.stringify(elem)
  if text:match("^%s*{{<%s*colbreak%s*>}}%s*$") or text == "" then
    if #elem.content == 0 or text:match("colbreak") then
      return {}
    end
  end
end

-- Replace <br> in headers with Typst line break "\ " and make the second line 18pt
function Header(elem)
  if quarto.doc.is_format("typst") then
    local br_idx = nil
    for i, inline in ipairs(elem.content) do
      if inline.t == "RawInline" and inline.format:match("html") and inline.text:lower():match("^<br%s*/?>$") then
        br_idx = i
        break
      end
    end
    if not br_idx then return nil end

    local new_content = {}
    for i, inline in ipairs(elem.content) do
      if i < br_idx then
        table.insert(new_content, inline)
      elseif i == br_idx then
        table.insert(new_content, pandoc.RawInline("typst", "\\ #text(size: 18pt)["))
      else
        table.insert(new_content, inline)
      end
    end
    table.insert(new_content, pandoc.RawInline("typst", "]"))
    elem.content = new_content
    return elem
  end
end


