return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("oil").setup({
            default_file_explorer = true,
            skip_confirm_for_simple_edits = false,
            view_options = {
                show_hidden = true,
            }
        })

        vim.keymap.set("n", "<leader>oo", require("oil").open)
        vim.keymap.set("n", "<leader>oc", require("oil").close)
    end,
}
