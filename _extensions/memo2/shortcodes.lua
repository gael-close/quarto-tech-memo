function appendix()
    return pandoc.RawBlock('typst', '#show: appendix')
end

-- Ignore column break in general except in poster 
-- see the dedicate rule in poster/shortcodes.lua
function colbreak()
    return pandoc.Str("")
end
