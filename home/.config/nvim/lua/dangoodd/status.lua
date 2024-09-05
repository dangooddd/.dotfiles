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
    return string.format(" %s ", map[vim.api.nvim_get_mode().mode] or "IDK")
end

local function filename()
    local path = vim.fn.expand("%:t")
    if path == "" then
        path = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.:h")
    end
    if path == "" then
        return " %m%r "
    end
    return string.format(" %%.30{'%s'} %%m%%r ", path)
end

local function position()
    return " %l:%c "
end

local function align()
    return "%="
end

local function filetype()
    local type = vim.bo.filetype
    if type == "" then
        return ""
    end
    return string.format(" %s ", type)
end

local function location()
    return " %p%% "
end

local function fullpath()
    return " %.60F "
end

function status_normal()
    return table.concat({
        mode(),
        filename(),
        align(),
        filetype(),
        location(),
        position(),
    })
end

function status_short()
    return table.concat({
        align(),
        fullpath(),
        align(),
    })
end

local augroup = vim.api.nvim_create_augroup 
local autocmd = vim.api.nvim_create_autocmd
local status_group = augroup("StatusLine", {})

autocmd({ "WinEnter", "BufEnter" }, {
    group = status_group,
    pattern = "*",
    callback = function()
        vim.opt_local.statusline = "%!v:lua.status_normal()" 
    end,
})

autocmd({ "WinLeave", "BufLeave" }, {
    group = status_group,
    pattern = "*",
    callback = function()
        vim.opt_local.statusline = "%!v:lua.status_short()" 
    end,
})
