-- Add wideblock div and ignore environments
function Div(elem)
  if elem.classes:includes("ignore") then
    return {}   -- drop the entire block and its children
  end
  return nil -- keep as is, or replace/transform if desired
end
