---------------------------------------
-- Options
---------------------------------------
vim.opt.clipboard = "unnamedplus"  -- use system clipboard
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.undofile = true  -- save state of file on write
vim.opt.autoread = true  -- autoread changes from other sources
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.wrap = false
vim.opt.scrolloff = 3
vim.opt.hlsearch = false  -- remove highlight on search 
vim.opt.pumheight = 10  -- size of completion window

-- tabs
vim.opt.tabstop = 4 -- 1 tab represented as 4 spaces
vim.opt.expandtab = true  -- <tab> key will create " " insead of "\t"
vim.opt.shiftwidth = 4  -- indent change after backspace and >> <<
vim.opt.softtabstop = 4  -- number of spaces instead of tab
vim.opt.smartindent = true  -- auto indent

-- global
vim.g.netrw_banner = 0
vim.g.mapleader = " "
vim.g.maplocal = [[\]]


---------------------------------------
-- Keybinds
---------------------------------------
vim.keymap.set("n", "<C-j>", vim.cmd.bnext)
vim.keymap.set("n", "<C-k>", vim.cmd.bprev)
vim.keymap.set("i", "<C-b>", "<Left>")
vim.keymap.set("i", "<C-f>", "<Right>")


---------------------------------------
-- Status Line
---------------------------------------
local Status = {}

function Status.filepath()
    return " %.60F "
end

function Status.errors()
    local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    if count == 0 then
        return ""
    end
    return string.format(" [E:%s] ", count)
end

function Status.warnings()
    local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    if count == 0 then
        return ""
    end
    return string.format(" [W:%s] ", count)
end

function Status.hints()
    local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    if count == 0 then
        return ""
    end
    return string.format(" [H:%s] ", count)
end

function Status.info()
    local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    if count == 0 then
        return ""
    end
    return string.format(" [I:%s] ", count)
end

function Status.position()
    return " %l:%c "
end

function Status.filetype()
    local type = vim.bo.filetype
    if type == "" then
        return ""
    end

    return string.format(" %s ", type)
end

function Status.location()
    return " %P "
end

-- Status Line function
function StatusLine()
    return table.concat({
        "%#StatusLine#",
        Status.filepath(),
        "%=",
        Status.errors(),
        Status.warnings(),
        Status.hints(),
        Status.info(),
        Status.position(),
        Status.filetype(),
        Status.location(),
    })
end

vim.opt.laststatus = 3  -- global statusline
vim.opt.showmode = true  -- show mode under statusline
vim.opt.statusline = "%!v:lua.StatusLine()"

-- auto update diagnostic
local group = vim.api.nvim_create_augroup("StatusLine", {})
vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = group,
    pattern = "*",
    callback = function()
        vim.opt.statusline = "%!v:lua.StatusLine()"
    end,
})
