return {
    "tpope/vim-fugitive",
    config = function()
        vim.keymap.set("n", "<leader>gg", ":Git ")
        vim.keymap.set("n", "<leader>gp", ":Git push ")
        vim.keymap.set("n", "<leader>ga", ":Git add ")
        vim.keymap.set("n", "<leader>gc", ":Git commit ")
        vim.keymap.set("n", "<leader>gl", ":vertical Git log ")
        vim.keymap.set("n", "<leader>gd", ":Gvdiffsplit ")
    end,
}
