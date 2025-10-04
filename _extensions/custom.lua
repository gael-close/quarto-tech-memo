
-- To debug the Lua filter, run it one dev.md minimum example file:
-- pandoc dev.md -t typst --lua-filter custom.lua 


-- Test/debugging functions

-- Function in Development
-- function Pandoc(doc)
--   print("\n## Inside Pandoc filter ##\n")
--   print(stringify_authors(authors))
-- return pandoc.Pandoc({}, doc.meta)
-- end





-- Utilities
function remove_class(classes, classname)
  local new_classes = {}
  for _, class in ipairs(classes) do
    if class ~= classname then
      table.insert(new_classes, class)
    end
  end
  return new_classes
end

--  Emulate my quarto.doc.is_format() if not running in Quarto
if not quarto then
  quarto = {}
  quarto.doc = {}
end
if not quarto.doc.is_format then
  -- Minimal Pandoc-compatible implementation
  function quarto.doc.is_format(fmt)
    return FORMAT == fmt or (FORMAT and FORMAT:match(fmt))
  end
end



-- Treat aside as node in typst
-- And a plain parenthesized text in Latex PDF
function Span(span)
  if span.classes:includes("aside") then
    if quarto.doc.is_format("typst") then
      return {
        pandoc.RawInline("typst", "#note(numbering: none, text-style: (size: 8pt))["),
        span,
        pandoc.RawInline("typst", "]")
    }
    else
      span.classes = remove_class(span.classes, "aside")
      return {
        pandoc.RawInline("latex", "["),
        span,
        pandoc.RawInline("latex", "]")
      } 
    end
  end
end

-- This single Table filter handles customizations for different output formats.
function Table (elem)
  -- For Typst: Format tables with automatic column widths, resolving the
  -- hard-coded full-width introduced by Quarto's built-in default table filter.
  if quarto.doc.is_format("typst") then
    for i, _ in ipairs(elem.colspecs) do
      elem.colspecs[i][2] = "auto"
    end

  end
  

  -- For PDF: Wrap tables in a custom `mytable` environment.
  -- The IEEE class does not support `longtable` without a workaround.
  -- See https://tex.stackexchange.com/a/224096
  if quarto.doc.is_format("pdf") then
    return {
      pandoc.RawBlock('latex', '\\begin{mytable}'),
      elem,
      pandoc.RawBlock('latex', '\\end{mytable}')
    }
  end

  -- Return the (potentially modified) table for all other formats.
  return elem
end


-- Add bibliography heading if there is a bibliography
-- and set the small font
function Pandoc(doc)
  if doc.meta.bibliography and quarto.doc.is_format("typst") then
    table.insert(doc.blocks, pandoc.RawBlock("typst", "#set text(size: 8pt)\n#set heading(numbering: none)\n\n= References"))
  end
  return doc
end




