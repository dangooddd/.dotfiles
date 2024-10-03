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
vim.opt.scrolloff = 5
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
