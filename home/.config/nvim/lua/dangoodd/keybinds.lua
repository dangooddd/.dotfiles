---------------------------------------
-- Keybinds
---------------------------------------
local keymap = vim.keymap

-- window managment
keymap.set('n', "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" } )
keymap.set('n', "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" } )
keymap.set('n', "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" } )
keymap.set('n', "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" } )
