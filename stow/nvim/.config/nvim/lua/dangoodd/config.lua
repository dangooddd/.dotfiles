--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------
vim.opt.clipboard = "unnamedplus" -- use system clipboard
vim.opt.guicursor:remove({ "t:block-blinkon500-blinkoff500-TermCursor" })
vim.opt.fillchars:append({ eob = " " })
vim.opt.winborder = "single"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.undofile = true -- save state of file on write
vim.opt.autoread = true -- autoread changes from other sources
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.wrap = false
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 3
vim.opt.ruler = false -- removes cursor position from lastline
vim.opt.hlsearch = false -- remove highlight on search
vim.opt.pumheight = 10 -- size of completion window
vim.opt.showmode = false -- do not show mode under statusline
vim.opt.shortmess:append("I") -- disable greeting
vim.opt.mouse = "a"

-- tabs
vim.opt.tabstop = 4 -- 1 tab represented as 4 spaces
vim.opt.expandtab = true -- <tab> key will create " " insead of "\t"
vim.opt.shiftwidth = 4 -- indent change after backspace and >> <<
vim.opt.softtabstop = 4 -- number of spaces instead of tab
vim.opt.autoindent = true -- auto indent
vim.opt.cinkeys:remove(":") -- shit.

-- global
vim.g.netrw_banner = 0
vim.g.clipboard = "osc52"
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- other
vim.treesitter.language.register("bash", "zsh")
vim.diagnostic.config({ virtual_text = true })

--------------------------------------------------------------------------------
-- Keybinds
--------------------------------------------------------------------------------
vim.keymap.set({ "i", "c" }, "<C-b>", "<Left>")
vim.keymap.set({ "i", "c" }, "<C-f>", "<Right>")
vim.keymap.set("n", "<leader>kd", vim.diagnostic.open_float)

-- toggle wrap
vim.keymap.set("n", "<leader>tw", function()
    vim.opt.wrap = not vim.o.wrap
end)

-- toggle inlay hints
vim.keymap.set("n", "<leader>th", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end)
