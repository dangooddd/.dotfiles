return {
    -- picker
    {
        "ibhagwan/fzf-lua",
        event = "VeryLazy",
        config = function()
            local fzf = require("fzf-lua")

            fzf.setup({
                fzf_colors = true,
                winopts = {
                    backdrop = 100,
                    title_flags = false,
                    preview = {
                        horizontal = "right:50%",
                        layout = "horizontal",
                    },
                },
            })

            vim.keymap.set("n", "<leader>ff", fzf.files)
            vim.keymap.set("n", "<leader>fh", fzf.helptags)
            vim.keymap.set("n", "<leader>fb", fzf.buffers)
            vim.keymap.set("n", "<leader>fg", fzf.git_files)
            vim.keymap.set("n", "<leader>fd", fzf.diagnostics_workspace)
            vim.keymap.set("n", "<leader>fl", fzf.live_grep)
            vim.keymap.set("n", "<leader>fz", fzf.builtin)
            vim.keymap.set("n", "<leader>fr", fzf.resume)
        end,
    },

    -- explorer
    {
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
    },
}
