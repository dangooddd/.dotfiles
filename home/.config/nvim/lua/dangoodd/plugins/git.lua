return {
    "tpope/vim-fugitive",
    config = function() 
        vim.keymap.set("n", "<leader>gs", ":Git ")
        vim.keymap.set("n", "<leader>gl", ":vertical Git log ")
        vim.keymap.set("n", "<leader>gd", ":Gvdiffsplit ")
    end,
}
