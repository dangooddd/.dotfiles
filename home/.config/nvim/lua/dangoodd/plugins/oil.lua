return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local border = "rounded"
        require("oil").setup({
            view_options = {
                show_hidden = true,
            },
            float = {
                win_options = {
                    winhighlight = "NormalNC:NormalFloat",
                },
            },
            keymaps = {
                ["q"] = { "actions.close", mode = "n" },
            },
        })

        vim.keymap.set("n", [[<leader>\]], require("oil").toggle_float)
    end,
}
