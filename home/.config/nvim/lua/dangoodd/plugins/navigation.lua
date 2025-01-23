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
                    preview = {
                        horizontal = "right:40%",
                        layout = "horizontal",
                    }
                },
                grep = {
                    cmd = "rg --hidden",
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

    -- track visited files
    {
        "dangooddd/chosen.nvim",
        keys = { "<Enter>" },
        config = function()
            require("chosen").setup()
            vim.keymap.set("n", "<Enter>", require("chosen").toggle)
        end,
    },
}
