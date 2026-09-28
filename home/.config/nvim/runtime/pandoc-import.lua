function Str(el)
    if el.text:match("^%[%d+%]$") then
        return pandoc.RawInline("markdown", el.text)
    end
end

function Div(el)
    if el.classes:includes("output") then
        return {}
    end

    if el.classes:includes("cell") then
        el.identifier = ""
        el.attributes = {}
    end

    return el
end
