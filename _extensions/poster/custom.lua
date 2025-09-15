-- Ignore the aside class and treat them as normal paragraphs
function remove_class(classes, classname)
  local new_classes = {}
  for _, class in ipairs(classes) do
    if class ~= classname then
      table.insert(new_classes, class)
    end
  end
  return new_classes
end


function Span(span)
  if span.classes:includes("aside") then
    span.classes = remove_class(span.classes, "aside")
    -- Teat aside like parenthesis
    return {
      pandoc.RawInline("typst", "("),
      span,
      pandoc.RawInline("typst", ")")
    }
    

  end
end

-- Format tables with automatic column widths
-- Resolving the hard coded full-width introduced by quarto built-in default table filter
function Table (tbl)
  -- print("## Inside table filter ##")
  for i, cs in ipairs(tbl.colspecs) do
    tbl.colspecs[i][2] = "auto"
  end
  
  return tbl
end


-- Add bibliography heading if there is a bibliography
-- and set the small font
function Pandoc(doc)
  if doc.meta.bibliography then
    table.insert(doc.blocks, pandoc.RawBlock("typst", "#set text(size: 8pt);#set heading(numbering: none);\n= References"))  
  end
  return doc
end

