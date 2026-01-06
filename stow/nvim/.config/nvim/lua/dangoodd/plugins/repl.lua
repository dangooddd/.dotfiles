return {
    {
        "benlubas/molten-nvim",
        dependencies = { "3rd/image.nvim" },
        build = ":UpdateRemotePlugins",
        init = function()
            vim.g.molten_image_provider = "image.nvim"
            vim.g.molten_wrap_output = true
            vim.g.molten_virt_text_output = true
            vim.g.molten_virt_lines_off_by_1 = true
            vim.g.molten_output_win_max_height = 30
            vim.g.molten_virt_text_max_lines = 20
            vim.g.molten_image_location = "float"
            vim.g.molten_output_win_hide_on_leave = false
            vim.g.molten_enter_output_behavior = "open_and_enter"

            vim.keymap.set("n", "<leader>ji", ":MoltenInit<CR>", { silent = true })
            vim.keymap.set("n", "<leader>jo", ":MoltenEvaluateOperator<CR>", { silent = true })
            vim.keymap.set("n", "<leader>jl", ":MoltenEvaluateLine<CR>", { silent = true })
            vim.keymap.set("n", "<leader>jc", ":MoltenReevaluateCell<CR>", { silent = true })
            vim.keymap.set("v", "<leader>jr", ":<C-u>MoltenEvaluateVisual<CR>", { silent = true })
            vim.keymap.set("n", "<leader>jd", ":MoltenDelete<CR>", { silent = true })
            vim.keymap.set("n", "<leader>jh", ":MoltenHideOutput<CR>", { silent = true })
            vim.keymap.set("n", "<leader>jo", ":noautocmd MoltenEnterOutput<CR>", { silent = true })
        end,
    },
    {
        "GCBallesteros/jupytext.nvim",
        config = function()
            require("jupytext").setup({
                style = "markdown",
                output_extension = "md",
                force_ft = "markdown",
            })
        end,
    },
    {
        "3rd/image.nvim",
        config = function()
            require("image").setup({
                backend = "kitty",
                max_width = 100,
                max_height = 12,
                max_height_window_percentage = math.huge,
                max_width_window_percentage = math.huge,
                window_overlap_clear_enabled = true,
            })
        end
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
        config = function()
            require("render-markdown").setup({
                completions = { blink = { enabled = true } },
                code = { border = "thin" },
            })
        end
    }
}
