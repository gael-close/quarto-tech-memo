-- function appendix()
--     return pandoc.RawBlock('latex', '#show: appendix')
-- end

function colbreak()
    return pandoc.RawBlock('latex', '')
end
