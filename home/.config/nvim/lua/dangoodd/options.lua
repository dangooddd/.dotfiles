---------------------------------------
-- Options
---------------------------------------
local opt = vim.opt
local g = vim.g

-- general
opt.clipboard = "unnamedplus"
opt.showmode = false
opt.number = true
opt.relativenumber = true
opt.undofile = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.cursorlineopt = "number"
opt.wrap = false
opt.pumheight = 10

-- tabs
opt.tabstop = 4        -- 1 tab represented as 4 spaces
opt.expandtab = true   -- <tab> key will create " " insead of "\t"
opt.shiftwidth = 4     -- indent change after backspace and >> <<
opt.softtabstop = 4    -- number of spaces instead of tab 
opt.smartindent = true -- auto indent

-- global
vim.g.mapleader = " "
vim.g.maplocal = "\\"
