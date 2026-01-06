return {
    "stevearc/oil.nvim",
    config = function()
        require("oil").setup({
            default_file_explorer = true,
            columns = { { "icon", add_padding = false } },
            view_options = { show_hidden = true },
            float = {
                max_width = 0.8,
                preview_split = "right",
                win_options = {
                    winhighlight = "NormalNC:NormalFloat",
                },
            },
            keymaps = {
                ["q"] = { "actions.close", mode = "n" },
            },
        })

        vim.keymap.set("n", [[\]], require("oil").toggle_float)
    end,
}
