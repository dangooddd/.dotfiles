---------------------------------------
-- StatusLine modules
---------------------------------------
local function filepath()
    return " %.60F "
end

local function errors()
    local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    if count == 0 then
        return ""
    end
    return string.format(" [E:%s] ", count)
end

local function warnings()
    local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    if count == 0 then
        return ""
    end
    return string.format(" [W:%s] ", count)
end

local function hints()
    local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    if count == 0 then
        return ""
    end
    return string.format(" [H:%s] ", count)
end

local function info()
    local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    if count == 0 then
        return ""
    end
    return string.format(" [I:%s] ", count)
end

local function position()
    return " %l:%c "
end

local function filetype()
    local type = vim.bo.filetype
    if type == "" then
        return ""
    end

    return string.format(" %s ", type)
end

local function location()
    return " %P "
end


---------------------------------------
-- StatusLine initialization
---------------------------------------
function StatusLine()
    return table.concat({
        "%#StatusLine#",
        filepath(),
        "%=",
        errors(),
        warnings(),
        hints(),
        info(),
        position(),
        filetype(),
        location(),
    })
end

vim.opt.laststatus = 3  -- global statusline
vim.opt.showmode = true  -- show mode under statusline
vim.opt.statusline = "%!v:lua.StatusLine()"
vim.api.nvim_create_augroup("StatusLine", {})

-- auto update diagnostic
vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = "StatusLine",
    pattern = "*",
    callback = function()
        vim.opt.statusline = "%!v:lua.StatusLine()"
    end,
})
