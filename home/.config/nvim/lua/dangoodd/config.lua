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
vim.opt.autoindent = true  -- auto indent
vim.opt.cinkeys = string.gsub(vim.o.cinkeys, ":,", "")  -- shit.

-- global
vim.g.netrw_banner = 0
vim.g.mapleader = " "
vim.g.maplocal = [[\]]


---------------------------------------
-- Keybinds
---------------------------------------
vim.keymap.set("n", "<C-j>", vim.cmd.bnext)
vim.keymap.set("n", "<C-k>", vim.cmd.bprev)
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename)
vim.keymap.set("i", "<C-b>", "<Left>")
vim.keymap.set("i", "<C-f>", "<Right>")


---------------------------------------
-- Status Line
---------------------------------------
local Status = {}

function Status.filepath()
    return " %t %m "
end

function Status.diagnostic()
    local diagnostic = {
        E = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }),
        W = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN }),
        H = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT }),
        I = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    }

    local line = ""
    for k, v in pairs(diagnostic) do
        if v > 0 then
            line = line..string.format("%s:%s,", k, v)
        end
    end

    if #line == 0 then return "" end
    line = string.sub(line, 0, -2)
    return string.format(" [%s] ", line)
end

function Status.position()
    return " %l:%c "
end

function Status.filetype()
    local type = vim.bo.filetype
    if type == "" then return "" end
    return string.format(" %s ", type)
end

function Status.branch()
    local branch = vim.b.git_branch
    if branch == nil then return "" end
    return string.format("  %s ", branch)
end

function Status.location()
    return " %P "
end

function Status.default_style()
    return "%#StatusLine#"
end

function Status.separator()
    return "%="
end

-- Status Line function
function StatusLine()
    return table.concat({
        Status.default_style(),
        Status.branch(),
        Status.filepath(),
        Status.separator(),
        Status.diagnostic(),
        Status.position(),
        Status.filetype(),
        Status.location(),
    })
end

vim.opt.laststatus = 3  -- global statusline
vim.opt.showmode = true  -- show mode under statusline
vim.opt.statusline = "%!v:lua.StatusLine()"

-- auto update diagnostic
local status_group = vim.api.nvim_create_augroup("StatusLine", {})
vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = status_group,
    pattern = "*",
    callback = function()
        vim.opt.statusline = "%!v:lua.StatusLine()"
    end,
})

-- display git branch in statusline
vim.api.nvim_create_autocmd("BufEnter", {
    group = status_group,
    pattern = "*",
    callback = function()
        local obj = vim.system(
            { "git", "branch", "--show-current" }, 
            { cwd = vim.fn.expand("%:p:h"), text = true } 
        ):wait()

        if obj.code == 0 then
            vim.b.git_branch = vim.trim(obj.stdout)
        end

        vim.opt.statusline = "%!v:lua.StatusLine()"
    end
})
