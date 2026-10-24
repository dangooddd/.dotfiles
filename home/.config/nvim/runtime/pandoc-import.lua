function RawInline(el)
    if el.format == "html" and el.text:match("^<img[%s>]") then
        local doc = pandoc.read(el.text, "html")
        if #doc.blocks == 1 and (doc.blocks[1].t == "Plain" or doc.blocks[1].t == "Para") then
            return doc.blocks[1].content
        end
    end
end

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
