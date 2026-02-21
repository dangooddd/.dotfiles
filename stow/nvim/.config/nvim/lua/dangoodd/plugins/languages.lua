return {
    -- default lsp configs
    {
        "neovim/nvim-lspconfig",
        config = function() end,
    },

    -- manager
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup({
                ui = {
                    backdrop = 100,
                },
            })
        end,
    },

    -- lua
    {
        "folke/lazydev.nvim",
        ft = "lua",
        config = function()
            require("lazydev").setup({
                library = {
                    {
                        path = "${3rd}/luv/library",
                        words = { "vim%.uv" },
                    },
                },
            })
        end,
    },

    -- typst
    {
        "chomosuke/typst-preview.nvim",
        ft = "typst",
        version = "1.*",
        config = function()
            require("typst-preview").setup({
                dependencies_bin = {
                    ["tinymist"] = vim.fn.exepath("tinymist"),
                },
            })
        end,
    },

    -- markdown
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("render-markdown").setup({
                completions = { lsp = { enabled = true } },
            })
        end,
    },

    -- python repl
    {
        "dangooddd/pyrepl.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            local pyrepl = require("pyrepl")
            pyrepl.setup()

            -- main commands
            vim.keymap.set("n", "<leader>jo", pyrepl.open_repl)
            vim.keymap.set("n", "<leader>jh", pyrepl.hide_repl)
            vim.keymap.set("n", "<leader>jc", pyrepl.close_repl)
            vim.keymap.set("n", "<leader>ji", pyrepl.open_image_history)
            vim.keymap.set({ "n", "t" }, "<C-j>", pyrepl.toggle_repl_focus)

            -- send commands
            vim.keymap.set("n", "<leader>jb", pyrepl.send_buffer)
            vim.keymap.set("n", "<leader>jl", pyrepl.send_cell)
            vim.keymap.set("v", "<leader>jv", pyrepl.send_visual)

            -- utility commands
            vim.keymap.set("n", "<leader>jp", pyrepl.step_cell_backward)
            vim.keymap.set("n", "<leader>jn", pyrepl.step_cell_forward)
            vim.keymap.set("n", "<leader>je", pyrepl.export_to_notebook)
            vim.keymap.set("n", "<leader>js", ":PyreplInstall")
        end,
    },
}
