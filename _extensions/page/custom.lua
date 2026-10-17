-- Drop .ignore divs entirely
function Div(elem)
  if elem.classes:includes("ignore") then
    return {}
  end
end

-- Remove {{< colbreak >}} paragraphs in page HTML
function Para(elem)
  if pandoc.utils.stringify(elem):match("^%s*{{<%s*colbreak%s*>}}%s*$") then
    return {}
  end
end
