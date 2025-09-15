function appendix()
    return pandoc.RawBlock('typst', '#show: appendix')
end

function colbreak()
    return pandoc.RawBlock('typst', '')
end
