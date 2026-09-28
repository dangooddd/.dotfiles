function Image(el)
    local mime, data = pandoc.mediabag.fetch(el.src)
    local name = pandoc.path.filename(el.src)
    pandoc.mediabag.insert(name, mime, data)
    el.src = name
    return el
end
