
-- IEEE class does not support `longtable` without a workaround
-- See https://tex.stackexchange.com/a/224096 
-- Wrapper for longtable in two-column mode and then fix in latex preamble


function Table (elem)
    return {
      pandoc.RawBlock('latex', '\\begin{mytable}'),
      elem,
      pandoc.RawBlock('latex', '\\end{mytable}')
    }
end

function remove_class(classes, classname)
  local new_classes = {}
  for _, class in ipairs(classes) do
    if class ~= classname then
      table.insert(new_classes, class)
    end
  end
  return new_classes
end

function Span(elem)
  -- Change '.myclass' to the class you want to remove
  elem.classes = remove_class(elem.classes, "aside")
  return elem
end

