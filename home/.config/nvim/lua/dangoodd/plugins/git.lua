return {
    "sindrets/diffview.nvim",
    config = function()
        vim.keymap.set("n", "<leader>do", ":DiffviewOpen")
        vim.keymap.set("n", "<leader>dc", ":DiffviewClose<CR>")
    end,
}

