return {
    -- picker
    {
        "ibhagwan/fzf-lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
        config = function()
            require("fzf-lua").setup({
                fzf_colors = true,
                winopts = {
                    backdrop = 100,
                    title_flags = false,
                    preview = {
                        horizontal = "right:40%",
                        layout = "horizontal",
                    }
                },
            })

            local fzf = require("fzf-lua")
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

    -- important files
    {
        "dangooddd/chosen.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = { "<Enter>" },
        cmd = "Chosen",
        config = function()
            require("chosen").setup({
                exit_on_save = true,
            })
            vim.keymap.set("n", "<Enter>", require("chosen").toggle)
        end,
    },
}
