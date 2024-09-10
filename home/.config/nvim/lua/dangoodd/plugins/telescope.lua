return {
    "nvim-telescope/telescope.nvim",
    dependencies = { 
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons"
    },
    config = function()
        require("telescope").setup({
            defaults = {
                layout_strategy = "horizontal",
                layout_config = {
                    prompt_position = "top",
                    horizontal = {
                        preview_cutoff = 40
                    }
                },
                sorting_strategy = "ascending",
            },
        })
        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>ff", builtin.find_files)
        vim.keymap.set("n", "<leader>fh", builtin.help_tags)
        vim.keymap.set("n", "<leader>fb", builtin.buffers)
        vim.keymap.set("n", "<leader>fg", builtin.git_files)
        vim.keymap.set("n", "<leader>fd", builtin.diagnostics)
        vim.keymap.set("n", "<leader>fl", builtin.live_grep)
    end,
}
