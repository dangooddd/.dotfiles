---------------------------------------
-- Options
---------------------------------------
vim.opt.clipboard = "unnamedplus"      -- use system clipboard
vim.opt.guicursor:append("a:blinkon0") -- remove cursor blink
vim.opt.winborder = "rounded"
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
vim.opt.ruler = false         -- removes cursor position from lastline
vim.opt.hlsearch = false      -- remove highlight on search
vim.opt.pumheight = 10        -- size of completion window
vim.opt.showmode = false      -- do not show mode under statusline
vim.opt.shortmess:append("I") -- disable greeting

-- tabs
vim.opt.tabstop = 4         -- 1 tab represented as 4 spaces
vim.opt.expandtab = true    -- <tab> key will create " " insead of "\t"
vim.opt.shiftwidth = 4      -- indent change after backspace and >> <<
vim.opt.softtabstop = 4     -- number of spaces instead of tab
vim.opt.autoindent = true   -- auto indent
vim.opt.cinkeys:remove(":") -- shit.
vim.opt.list = true
vim.opt.listchars:append("lead:·")

-- global
vim.g.netrw_banner = 0
vim.g.mapleader = " "
vim.g.maplocal = " "


---------------------------------------
-- Keybinds
---------------------------------------
vim.keymap.set("n", "<C-j>", vim.cmd.bnext)
vim.keymap.set("n", "<C-k>", vim.cmd.bprev)

vim.keymap.set({ "i", "c" }, "<C-b>", "<Left>")
vim.keymap.set({ "i", "c" }, "<C-f>", "<Right>")

vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename)
vim.keymap.set("n", "`", "'", { noremap = true }) -- better marks

-- for merging
vim.keymap.set("n", "<leader>1", "<cmd>diffget LO")
vim.keymap.set("n", "<leader>2", "<cmd>diffget BA")
vim.keymap.set("n", "<leader>3", "<cmd>diffget RE")

-- toggle wrap
vim.keymap.set("n", "<leader>tw", function()
    vim.opt.wrap = not vim.o.wrap
end)

-- toggle inlay hints
vim.keymap.set("n", "<leader>th", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end)
