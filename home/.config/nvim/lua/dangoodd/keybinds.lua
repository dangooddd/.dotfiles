---------------------------------------
-- Keybinds
---------------------------------------
local keymap = vim.keymap

-- window managment
keymap.set("n", "<C-h>", "<C-w><C-h>", {})
keymap.set("n", "<C-l>", "<C-w><C-l>", {})
keymap.set("n", "<C-j>", "<C-w><C-j>", {})
keymap.set("n", "<C-k>", "<C-w><C-k>", {})

-- buffer navigation
keymap.set("n", "<leader>bn", ":bnext<CR>", {})
keymap.set("n", "<leader>bp", ":bprev<CR>", {})
