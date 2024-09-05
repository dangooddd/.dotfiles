return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("oil").setup({
            default_file_explorer = true,
            skip_confirm_for_simple_edits = false,
            watch_for_changes = true,
            columns = {},
            win_options = {
                signcolumn = "yes"
            },
            view_options = {
                show_hidden = true,
                is_always_hidden = function(name, _)
                    return name == ".."
                end,
            },
            float = { preview_split = "right" },
        })
        vim.keymap.set("n", [[<leader>\]], require("oil").toggle_float)
    end,
}
