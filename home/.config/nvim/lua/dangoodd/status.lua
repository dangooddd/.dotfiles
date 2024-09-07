local function mode()
    local map = {
        ["n"] = "NORMAL",
        ["no"] = "O-PENDING",
        ["nov"] = "O-PENDING",
        ["noV"] = "O-PENDING",
        ["no\22"] = "O-PENDING",
        ["niI"] = "NORMAL",
        ["niR"] = "NORMAL",
        ["niV"] = "NORMAL",
        ["nt"] = "NORMAL",
        ["ntT"] = "NORMAL",
        ["v"] = "VISUAL",
        ["vs"] = "VISUAL",
        ["V"] = "V-LINE",
        ["Vs"] = "V-LINE",
        ["\22"] = "V-BLOCK",
        ["\22s"] = "V-BLOCK",
        ["s"] = "SELECT",
        ["S"] = "S-LINE",
        ["\19"] = "S-BLOCK",
        ["i"] = "INSERT",
        ["ic"] = "INSERT",
        ["ix"] = "INSERT",
        ["R"] = "REPLACE",
        ["Rc"] = "REPLACE",
        ["Rx"] = "REPLACE",
        ["Rv"] = "V-REPLACE",
        ["Rvc"] = "V-REPLACE",
        ["Rvx"] = "V-REPLACE",
        ["c"] = "COMMAND",
        ["cv"] = "EX",
        ["ce"] = "EX",
        ["r"] = "REPLACE",
        ["rm"] = "MORE",
        ["r?"] = "CONFIRM",
        ["!"] = "SHELL",
        ["t"] = "TERMINAL",
    }
    local mode_name = map[vim.api.nvim_get_mode().mode] or "IDK"
    return " " .. mode_name .. " "
end

local function diagnostic()
    local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    if errors > 0 then
        return string.format(" [E:%s] ", errors)
    end

    local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    if warnings > 0 then
        return string.format(" [W:%s] ", warnings)
    end

    local hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    if hints > 0 then
        return string.format(" [H:%s] ", hints)
    end

    local infos = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    if infos > 0 then
        return string.format(" [I:%s] ", infos)
    end

    return ""
end

local function filename()
    return " %.60F %m%r "
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

function StatusLine()
    return table.concat({
        "%#StatusLine#",
        mode(),
        filename(),
        "%=",
        diagnostic(),
        position(),
        filetype(),
        location(),
    })
end

vim.opt.laststatus = 3
vim.opt.statusline = "%!v:lua.StatusLine()"

-- auto update diagnostic
vim.api.nvim_create_augroup("StatusLine", {})
vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = "StatusLine",
    pattern = "*",
    callback = function()
        vim.opt.statusline = "%!v:lua.StatusLine()"
    end,
})
